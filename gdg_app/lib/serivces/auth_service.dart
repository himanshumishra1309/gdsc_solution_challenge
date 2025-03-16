import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

enum UserType {
  admin,
  coach,
  athlete,
  sponsor,
  independentAthlete,
  unknown
}

class AuthService {
  Future<bool> testConnection() async {
    try {
      print('Testing API connection to: ${ApiConstants.healthCheck}');
      
      final response = await http.get(
        Uri.parse(ApiConstants.healthCheck),
      ).timeout(const Duration(seconds: 10)); // Increased timeout
      
      print('API Connection test: ${response.statusCode}');
      print('API Response: ${response.body}');
      return response.statusCode == 200;
    } on TimeoutException {
      print('API Connection test failed: Request timed out');
      return false;
    } catch (e) {
      print('API Connection test failed with error: $e');
      return false;
    }
  }
  // Determine user type from source page
  UserType getUserTypeFromSourcePage(String sourcePage) {
    switch (sourcePage) {
      case 'adminHome':
        return UserType.admin;
      case 'coachHome':
        return UserType.coach;
      case 'playerHome':
        return UserType.athlete;
      case 'sponsorRegister':
        return UserType.sponsor;
      case 'individualRegister':
        return UserType.independentAthlete;
      default:
        return UserType.unknown;
    }
  }

  // Main login method that routes to the appropriate login endpoint
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required UserType userType,
  }) async {
    switch (userType) {
      case UserType.admin:
        return await _loginAdmin(email, password);
      case UserType.coach:
        return await _loginCoach(email, password);
      case UserType.athlete:
        return await _loginAthlete(email, password);
      case UserType.sponsor:
        return await _loginSponsor(email, password);
      case UserType.independentAthlete:
        return await _loginIndependentAthlete(email, password);
      default:
        return {
          'success': false,
          'message': 'Unknown user type'
        };
    }
  }
  
  // Admin login
  Future<Map<String, dynamic>> _loginAdmin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.adminLogin),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      return _processLoginResponse(response, UserType.admin);
    } catch (e) {
      print('Admin login error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
  
  // Coach login
  Future<Map<String, dynamic>> _loginCoach(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.coachLogin),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      return _processLoginResponse(response, UserType.coach);
    } catch (e) {
      print('Coach login error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
  
  // Athlete login
  Future<Map<String, dynamic>> _loginAthlete(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.athleteLogin),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      return _processLoginResponse(response, UserType.athlete);
    } catch (e) {
      print('Athlete login error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
  
  // Sponsor login
  Future<Map<String, dynamic>> _loginSponsor(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.sponsorLogin),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      return _processLoginResponse(response, UserType.sponsor);
    } catch (e) {
      print('Sponsor login error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
  
  // Independent athlete login
  Future<Map<String, dynamic>> _loginIndependentAthlete(String email, String password) async {
    try {
      print('Attempting login to: ${ApiConstants.independentAthleteLogin}');
      print('Device platform specific URL being used');
      
      final response = await http.post(
        Uri.parse(ApiConstants.independentAthleteLogin),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 25)); // Longer timeout for login
      
      print('Login response status: ${response.statusCode}');
      return _processLoginResponse(response, UserType.independentAthlete);
    } on TimeoutException {
      print('Independent athlete login timeout - server unreachable');
      return {
        'success': false,
        'message': 'Server is taking too long to respond. Please try again later.',
      };
    } on http.ClientException catch (e) {
      print('Independent athlete login client error: $e');
      String errorMessage = 'Network error';
      
      if (e.toString().contains('Connection refused')) {
        errorMessage = 'Cannot connect to server. Please check if the server is running.';
      } else if (e.toString().contains('Connection timed out')) {
        errorMessage = 'Connection timed out. Please check your internet connection.';
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('Independent athlete login error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }
  
  // Helper method to process login responses
  Future<Map<String, dynamic>> _processLoginResponse(http.Response response, UserType userType) async {
    try {
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Extract tokens and user data based on user type
        String? accessToken;
        String? refreshToken;
        Map<String, dynamic> userData = {};
        
        if (responseData['data'] != null) {
          userData = responseData['data']['user'] ?? {};
          
          // Extract tokens based on user type
          switch (userType) {
            case UserType.admin:
              accessToken = responseData['data']['adminAccessToken'];
              refreshToken = responseData['data']['adminRefreshToken'];
              break;
            case UserType.coach:
              accessToken = responseData['data']['coachAccessToken'];
              refreshToken = responseData['data']['coachRefreshToken'];
              break;
            case UserType.athlete:
            case UserType.independentAthlete:
              accessToken = responseData['data']['athleteAccessToken'];
              refreshToken = responseData['data']['athleteRefreshToken'];
              break;
            case UserType.sponsor:
              accessToken = responseData['data']['sponsorAccessToken'];
              refreshToken = responseData['data']['sponsorRefreshToken'];
              break;
            default:
              break;
          }
        }
        
        // Save auth data to SharedPreferences
        await _saveAuthData(userType, accessToken, refreshToken, userData);
        
        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'userType': userType.toString(),
          'userData': userData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error processing login response: $e');
      return {
        'success': false,
        'message': 'Failed to process server response: $e',
      };
    }
  }
  
  // Save authentication data to SharedPreferences
  Future<void> _saveAuthData(
    UserType userType, 
    String? accessToken, 
    String? refreshToken,
    Map<String, dynamic> userData
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('userType', userType.toString());
      
      if (accessToken != null) {
        await prefs.setString('accessToken', accessToken);
      }
      
      if (refreshToken != null) {
        await prefs.setString('refreshToken', refreshToken);
      }
      
      // Save user data as JSON string
      if (userData.isNotEmpty) {
        await prefs.setString('userData', jsonEncode(userData));
        
        // Save user ID for convenience
        if (userData['_id'] != null) {
          await prefs.setString('userId', userData['_id']);
        }
        
        // Save organization ID if it exists
        if (userData['organization'] != null) {
          if (userData['organization'] is String) {
            await prefs.setString('organizationId', userData['organization']);
          } else if (userData['organization'] is Map && userData['organization']['_id'] != null) {
            await prefs.setString('organizationId', userData['organization']['_id']);
          }
        }

        // Save additional fields for convenience
        if (userData['name'] != null) {
          await prefs.setString('userName', userData['name']);
        }
        
        if (userData['email'] != null) {
          await prefs.setString('userEmail', userData['email']);
        }
        
        if (userData['avatar'] != null) {
          await prefs.setString('userAvatar', userData['avatar']);
        }
      }
      
      // Save login timestamp
      await prefs.setInt('loginTime', DateTime.now().millisecondsSinceEpoch);
      
    } catch (e) {
      print('Error saving auth data: $e');
      // Consider how to handle this error - maybe throw it
      // or implement a retry mechanism
    }
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('accessToken') && prefs.containsKey('userType');
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }
  
  // Get user type
  Future<UserType> getUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userTypeStr = prefs.getString('userType');
      
      if (userTypeStr == null) return UserType.unknown;
      
      switch (userTypeStr) {
        case 'UserType.admin':
          return UserType.admin;
        case 'UserType.coach':
          return UserType.coach;
        case 'UserType.athlete':
          return UserType.athlete;
        case 'UserType.sponsor':
          return UserType.sponsor;
        case 'UserType.independentAthlete':
          return UserType.independentAthlete;
        default:
          return UserType.unknown;
      }
    } catch (e) {
      print('Error getting user type: $e');
      return UserType.unknown;
    }
  }
  
  // Get user data
  Future<Map<String, dynamic>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('userData');
      
      if (userDataStr != null) {
        return jsonDecode(userDataStr) as Map<String, dynamic>;
      }
      
      return {};
    } catch (e) {
      print('Error getting user data: $e');
      return {};
    }
  }
  
  // Refresh the access token
  Future<Map<String, dynamic>> refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');
      final userType = await getUserType();
      
      if (refreshToken == null || userType == UserType.unknown) {
        return {
          'success': false,
          'message': 'No refresh token available or unknown user type'
        };
      }
      
      final response = await http.post(
        Uri.parse(ApiConstants.refreshToken),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
          'userType': userType.toString().split('.').last, // Convert enum to string
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['data']['accessToken'];
        
        if (newAccessToken != null) {
          await prefs.setString('accessToken', newAccessToken);
          
          return {
            'success': true,
            'message': 'Token refreshed successfully'
          };
        }
      }
      
      return {
        'success': false,
        'message': 'Failed to refresh token'
      };
    } catch (e) {
      print('Error refreshing token: $e');
      return {
        'success': false,
        'message': 'Error refreshing token: $e'
      };
    }
  }
  
  // Logout - clear all stored data
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error during logout: $e');
      // Consider how to handle this error
    }
  }
}