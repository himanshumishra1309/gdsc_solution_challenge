import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/routes.dart';
import 'dart:math';

enum UserType { admin, coach, athlete, sponsor, independentAthlete, unknown }

class AuthService {
  Future<bool> testConnection() async {
    try {
      print('Testing API connection to: ${ApiConstants.healthCheck}');

      final response = await http
          .get(
            Uri.parse(ApiConstants.healthCheck),
          )
          .timeout(const Duration(seconds: 10)); // Increased timeout

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

  // Gets the correct home route based on designation
  String getRouteBasedOnDesignation(String designation) {
    // Standardize designation string for comparison
    final normalizedDesignation = designation.trim().toLowerCase();
    
    print('Determining route based on designation: $normalizedDesignation');
    
    if (normalizedDesignation.contains('medical')) {
      print('Routing to Medical Staff Home');
      return medicalStaffHomeRoute;
    } else if (normalizedDesignation.contains('coach')) {
      print('Routing to Coach Home');
      return coachHomeRoute;
    } else if (normalizedDesignation.contains('trainer')) {
      print('Routing to Trainer Home');
      return trainerHomeRoute;
    } else {
      // Default route if designation is unrecognized
      print('Unrecognized designation, defaulting to Coach Home');
      return coachHomeRoute;
    }
  }

  // Main login method that routes to the appropriate login endpoint
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required UserType userType,
  }) async {
    Map<String, dynamic> result;
    
    switch (userType) {
      case UserType.admin:
        result = await _loginAdmin(email, password);
        break;
      case UserType.coach:
        result = await _loginCoach(email, password);
        break;
      case UserType.athlete:
        result = await _loginAthlete(email, password);
        break;
      case UserType.sponsor:
        result = await _loginSponsor(email, password);
        break;
      case UserType.independentAthlete:
        result = await _loginIndependentAthlete(email, password);
        break;
      default:
        result = {'success': false, 'message': 'Unknown user type'};
    }
    
    if (result['success'] && !result.containsKey('targetRoute')) {
      // If login successful but no target route (for backward compatibility)
      // Get user designation and determine route
      final designation = await getUserDesignation();
      if (designation.isNotEmpty) {
        result['targetRoute'] = getRouteBasedOnDesignation(designation);
      } else {
        // Default route if designation is not available
        result['targetRoute'] = coachHomeRoute;
      }
    }
    
    return result;
  }

  // Add this method to your AuthService class
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      // First check if we have cached user data
      final prefs = await SharedPreferences.getInstance();
      final userType = await getUserType();

      // Try to get data from SharedPreferences first for quick loading
      final cachedUserData = prefs.getString('userData');
      Map<String, dynamic> userData = {};

      if (cachedUserData != null) {
        userData = jsonDecode(cachedUserData);
        debugPrint("Loaded user data from cache: ${userData['name']}");
      }

      // Determine the profile endpoint based on user type
      String profileEndpoint = '';

      switch (userType) {
        case UserType.admin:
          profileEndpoint = '${ApiConstants.baseUrl}/api/v1/admins/profile';
          break;
        case UserType.coach:
          profileEndpoint = '${ApiConstants.baseUrl}/api/v1/coaches/profile';
          break;
        case UserType.athlete:
          profileEndpoint = '${ApiConstants.baseUrl}/api/v1/athletes/profile';
          break;
        case UserType.independentAthlete:
          profileEndpoint =
              '${ApiConstants.baseUrl}/api/v1/individual-athletes/profile';
          break;
        case UserType.sponsor:
          profileEndpoint = '${ApiConstants.baseUrl}/api/v1/sponsors/profile';
          break;
        default:
          return userData; // Return cached data if no valid user type
      }

      // Make API call to get fresh user data
      final response = await http.get(
        Uri.parse(profileEndpoint),
        headers: await getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Extract user data differently depending on user type
        Map<String, dynamic> freshUserData;

        if (userType == UserType.admin) {
          freshUserData = responseData['data'] ?? {};
        } else if (userType == UserType.sponsor) {
          freshUserData = responseData['data']['sponsor'] ?? {};
        } else {
          freshUserData = responseData['data'] ?? {};
        }

        // Save the updated user data to cache
        await prefs.setString('userData', jsonEncode(freshUserData));

        // Update other user fields
        if (freshUserData['name'] != null) {
          await prefs.setString('userName', freshUserData['name']);
        }

        if (freshUserData['email'] != null) {
          await prefs.setString('userEmail', freshUserData['email']);
        }

        if (freshUserData['avatar'] != null) {
          await prefs.setString('userAvatar', freshUserData['avatar']);
        }

        // Save role if available
        if (freshUserData['role'] != null) {
          await prefs.setString('userRole', freshUserData['role']);
        }

        // Save designation if available
        if (freshUserData['designation'] != null) {
          await prefs.setString('userDesignation', freshUserData['designation']);
        }

        return freshUserData;
      } else {
        // If API request fails, return cached data
        debugPrint(
            'Failed to get user profile. Status: ${response.statusCode}');
        return userData;
      }
    } catch (e) {
      debugPrint('Error getting current user: $e');

      // Return basic user info from preferences as fallback
      final prefs = await SharedPreferences.getInstance();
      return {
        'name': prefs.getString('userName') ?? 'User',
        'email': prefs.getString('userEmail') ?? '',
        'avatar': prefs.getString('userAvatar'),
        'role': prefs.getString('userRole') ?? '',
        'designation': prefs.getString('userDesignation') ?? '',
      };
    }
  }

  // Get user role
  Future<String> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userRole') ?? '';
    } catch (e) {
      print('Error getting user role: $e');
      return '';
    }
  }

  // Get user designation
  Future<String> getUserDesignation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userDesignation') ?? '';
    } catch (e) {
      print('Error getting user designation: $e');
      return '';
    }
  }

  Future<Map<String, dynamic>> _loginAdmin(
      String email, String password) async {
    try {
      final url = ApiConstants.adminLogin;
      print('Sending admin login request to: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Admin login response status: ${response.statusCode}');
      print(
          'Response starts with: ${response.body.substring(0, min(100, response.body.length))}');

      return _processLoginResponse(response, UserType.admin);
    } catch (e) {
      print('Admin login error: $e');
      return {
        'success': false,
        'message':
            'Network error: ${e.toString().substring(0, min(100, e.toString().length))}',
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
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    
    // Add debugging to see the response
    print('Coach login response: ${response.statusCode}');
    print('Coach login body: ${response.body}');
    
    return _processLoginResponse(response, UserType.coach);
  } catch (e) {
    // More detailed error logging
    print('Coach login error: $e');
    return {'success': false, 'message': 'Login failed: $e'};
  }
}

  // Athlete login
  Future<Map<String, dynamic>> _loginAthlete(
      String email, String password) async {
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
  Future<Map<String, dynamic>> _loginSponsor(
      String email, String password) async {
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
  Future<Map<String, dynamic>> _loginIndependentAthlete(
      String email, String password) async {
    try {
      print('Attempting login to: ${ApiConstants.independentAthleteLogin}');
      print('Device platform specific URL being used');

      final response = await http
          .post(
            Uri.parse(ApiConstants.independentAthleteLogin),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 25)); // Longer timeout for login

      print('Login response status: ${response.statusCode}');
      return _processLoginResponse(response, UserType.independentAthlete);
    } on TimeoutException {
      print('Independent athlete login timeout - server unreachable');
      return {
        'success': false,
        'message':
            'Server is taking too long to respond. Please try again later.',
      };
    } on http.ClientException catch (e) {
      print('Independent athlete login client error: $e');
      String errorMessage = 'Network error';

      if (e.toString().contains('Connection refused')) {
        errorMessage =
            'Cannot connect to server. Please check if the server is running.';
      } else if (e.toString().contains('Connection timed out')) {
        errorMessage =
            'Connection timed out. Please check your internet connection.';
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

  Future<void> printAllPrefs() async {
    try {
      print('\n\n🔍🔍🔍 BEGINNING SHARED PREFERENCES INSPECTION 🔍🔍🔍');

      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      print('📋 Total keys found: ${keys.length}');

      if (keys.isEmpty) {
        print('❌ NO KEYS FOUND IN SHARED PREFERENCES - STORAGE IS EMPTY');
      } else {
        print('---- SHARED PREFERENCES CONTENTS ----');
        for (String key in keys) {
          final value = prefs.get(key);
          print('🔑 $key: $value  (Type: ${value?.runtimeType})');
        }
      }

      // Check for specific authentication keys we expect
      final List<String> authKeys = [
        'userType',
        'userId',
        'token',
        'refreshToken',
        'individualAthleteAccessToken',
        'individualAthleteRefreshToken',
        'coachAccessToken',
        'coachRefreshToken',
        'adminAccessToken',
        'adminRefreshToken',
        'sponsorAccessToken',
        'sponsorRefreshToken',
        'userRole',
        'userDesignation'
      ];

      print('\n🔐 CHECKING FOR AUTH KEYS:');
      for (String key in authKeys) {
        final hasKey = prefs.containsKey(key);
        print('$key: ${hasKey ? "✅ PRESENT" : "❌ MISSING"}');
      }

      print('🔍🔍🔍 END OF SHARED PREFERENCES INSPECTION 🔍🔍🔍\n\n');
    } catch (e) {
      print('❌❌❌ ERROR INSPECTING SHARED PREFERENCES: $e ❌❌❌');
    }
  }

// Add this method to your AuthService class
  Future<bool> logout() async {
    try {
      print('\n🚪 STARTING LOGOUT PROCESS');

      // First print all prefs for debugging
      await printAllPrefs();

      final prefs = await SharedPreferences.getInstance();
      final userType =
          prefs.getString('userType'); // GET the value, don't SET it

      print('Logging out user type: $userType');

      // Call the appropriate logout endpoint based on user type
      String logoutEndpoint = '';
      if (userType == null) {
        print('No user type found in preferences');
      } else if (userType == 'UserType.admin') {
        logoutEndpoint = ApiConstants.adminLogout;
      } else if (userType == 'UserType.coach') {
        logoutEndpoint = ApiConstants.coachLogout;
      } else if (userType == 'UserType.athlete') {
        logoutEndpoint = ApiConstants.athleteLogout;
      } else if (userType == 'UserType.independentAthlete') {
        logoutEndpoint = ApiConstants.independentAthleteLogout;
      } else if (userType == 'UserType.sponsor') {
        logoutEndpoint = ApiConstants.sponsorLogout;
      }

      // If we have a valid endpoint, call it
      bool serverLogoutSuccess = true;
      if (logoutEndpoint.isNotEmpty) {
        try {
          print('Calling logout endpoint: $logoutEndpoint');
          final response = await http
              .post(
                Uri.parse(logoutEndpoint),
                headers: await getAuthHeaders(),
              )
              .timeout(const Duration(seconds: 5));

          print('Logout response: ${response.statusCode}');
          serverLogoutSuccess =
              response.statusCode >= 200 && response.statusCode < 300;
        } catch (e) {
          print('Error calling logout endpoint: $e');
          // Continue with local logout even if server logout fails
          serverLogoutSuccess = false;
        }
      }

      // Always clear local storage regardless of server response
      await prefs.clear();

      // Clear specific tokens based on user type
      if (userType == 'UserType.admin') {
        await prefs.remove('adminAccessToken');
        print('removed adminAccessToken');
        await prefs.remove('adminRefreshToken');
        print('removed adminRefreshToken');
      } else if (userType == 'UserType.coach') {
        await prefs.remove('coachAccessToken');
        await prefs.remove('coachRefreshToken');
      } else if (userType == 'UserType.athlete') {
        await prefs.remove('athleteAccessToken');
        await prefs.remove('athleteRefreshToken');
      } else if (userType == 'UserType.independentAthlete') {
        await prefs.remove('individualAthleteAccessToken');
        await prefs.remove('individualAthleteRefreshToken');
      } else if (userType == 'UserType.sponsor') {
        await prefs.remove('sponsorAccessToken');
        await prefs.remove('sponsorRefreshToken');
      }

      // Also clear user role and designation
      await prefs.remove('userRole');
      await prefs.remove('userDesignation');

      print('User logged out locally: $userType');
      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }

// Helper method to get authentication headers
  Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');

    String? token;
    if (userType == 'admin') {
      token = prefs.getString('adminAccessToken');
    } else if (userType == 'coach') {
      token = prefs.getString('coachAccessToken');
    } else if (userType == 'athlete') {
      token = prefs.getString('athleteAccessToken');
    } else if (userType == 'independentAthlete') {
      token = prefs.getString('individualAthleteAccessToken');
    } else if (userType == 'sponsor') {
      token = prefs.getString('sponsorAccessToken');
    } else {
      token = prefs.getString('token');
    }

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method to process login responses
  Future<Map<String, dynamic>> _processLoginResponse(
      http.Response response, UserType userType) async {
    try {
      // Check if response is HTML instead of JSON (connection issue)
      if (response.body.trim().toLowerCase().startsWith('<!doctype html') ||
          response.body.trim().toLowerCase().startsWith('<html')) {
        print('ERROR: Received HTML response instead of JSON');
        print('Response starts with: ${response.body.substring(0, 100)}...');

        return {
          'success': false,
          'message': 'Server connection error. Check network settings.',
        };
      }

      final responseData = jsonDecode(response.body);
      print('Full login response: ${response.body}');

      if (response.statusCode == 200) {
        // Extract tokens and user data based on user type
        String? accessToken;
        String? refreshToken;
        Map<String, dynamic> userData = {};
        String userRole = '';
        String userDesignation = '';
        String targetRoute = coachHomeRoute; // Default route

        if (responseData['data'] != null) {
          // Special handling for admin user data - it's in 'admin', not 'user'
          if (userType == UserType.admin) {
            userData = responseData['data']['admin'] ?? {};
            print('Admin data extracted: ${jsonEncode(userData)}');

            // Store full response data for debugging & later use
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(
                'adminResponseData', jsonEncode(responseData['data']));

            // Store organization ID separately - critical for admin registration
            if (responseData['data']['admin'] != null &&
                responseData['data']['admin']['organization'] != null) {
              final orgId =
                  responseData['data']['admin']['organization'].toString();
              await prefs.setString('organizationId', orgId);
              print('✅ Organization ID saved from admin login: $orgId');
            }
          } else if (userType == UserType.coach) {
            // For coach, the data is in 'coach'
            userData = responseData['data']['coach'] ?? {};
            print('Coach data extracted: ${jsonEncode(userData)}');
          } else {
            // Other user types use standard 'user' key
            userData = responseData['data']['user'] ?? {};
          }

          // Extract user role and designation if available
          if (userData.containsKey('role')) {
            userRole = userData['role'] ?? '';
            print('Found user role: $userRole');
          }
          
          if (userData.containsKey('designation')) {
            userDesignation = userData['designation'] ?? '';
            print('Found user designation: $userDesignation');
            
            // Determine route based on designation
            targetRoute = getRouteBasedOnDesignation(userDesignation);
            print('Determined target route: $targetRoute based on designation: $userDesignation');
          }

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
              accessToken = responseData['data']['athleteAccessToken'];
              refreshToken = responseData['data']['athleteRefreshToken'];
              break;
            case UserType.independentAthlete:
              accessToken =
                  responseData['data']['individualAthleteAccessToken'];
              refreshToken =
                  responseData['data']['individualAthleteRefreshToken'];
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
          'role': userRole,
          'designation': userDesignation,
          'targetRoute': targetRoute,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ??
              'Login failed. Status code: ${response.statusCode}',
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

// Updated _saveAuthData method with enhanced organization ID handling
  Future<void> _saveAuthData(UserType userType, String? accessToken,
      String? refreshToken, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('userType', userType.toString());

      if (accessToken != null) {
        await prefs.setString('accessToken', accessToken);
        print(
            '✅ Saved access token: ${accessToken.substring(0, min(20, accessToken.length))}...');

        // Also save type-specific token for legacy code
        switch (userType) {
          case UserType.admin:
            await prefs.setString('adminAccessToken', accessToken);
            break;
          case UserType.coach:
            await prefs.setString('coachAccessToken', accessToken);
            break;
          case UserType.athlete:
            await prefs.setString('athleteAccessToken', accessToken);
            break;
          case UserType.independentAthlete:
            await prefs.setString('individualAthleteAccessToken', accessToken);
            break;
          case UserType.sponsor:
            await prefs.setString('sponsorAccessToken', accessToken);
            break;
          default:
            break;
        }
      }

      if (refreshToken != null) {
        await prefs.setString('refreshToken', refreshToken);
        print(
            '✅ Saved refresh token: ${refreshToken.substring(0, min(20, refreshToken.length))}...');

        // Also save type-specific refresh token
        switch (userType) {
          case UserType.admin:
            await prefs.setString('adminRefreshToken', refreshToken);
            break;
          case UserType.coach:
            await prefs.setString('coachRefreshToken', refreshToken);
            break;
          case UserType.athlete:
            await prefs.setString('athleteRefreshToken', refreshToken);
            break;
          case UserType.independentAthlete:
            await prefs.setString(
                'individualAthleteRefreshToken', refreshToken);
            break;
          case UserType.sponsor:
            await prefs.setString('sponsorRefreshToken', refreshToken);
            break;
          default:
            break;
        }
      }

      // Save user data as JSON string
      if (userData.isNotEmpty) {
        await prefs.setString('userData', jsonEncode(userData));
        print(
            '✅ Saved user data: ${jsonEncode(userData).substring(0, min(100, jsonEncode(userData).length))}...');

        // Save user ID for convenience
        if (userData['_id'] != null) {
          await prefs.setString('userId', userData['_id']);
          print('✅ Saved user ID: ${userData['_id']}');
        }

        // Save user role if present
        if (userData['role'] != null) {
          await prefs.setString('userRole', userData['role']);
          print('✅ Saved user role: ${userData['role']}');
        }
        
        // Save user designation if present
        if (userData['designation'] != null) {
          await prefs.setString('userDesignation', userData['designation']);
          print('✅ Saved user designation: ${userData['designation']}');
        }

        // Special handling for organization ID
        if (userType == UserType.admin) {
          String? organizationId;

          // Try multiple ways to extract organization ID
          if (userData['organization'] != null) {
            if (userData['organization'] is String) {
              organizationId = userData['organization'];
              print('✅ Found organization ID as string: $organizationId');
            } else if (userData['organization'] is Map) {
              organizationId = userData['organization']['_id']?.toString();
              print('✅ Found organization ID in map: $organizationId');
            }
          }

          if (organizationId != null) {
            await prefs.setString('organizationId', organizationId);
            print('✅ Saved organization ID: $organizationId');
          } else {
            print('⚠️ Could not find organization ID in admin data');
          }
        } else {
          // For non-admin users, just save organization if present
          if (userData['organization'] != null) {
            if (userData['organization'] is String) {
              await prefs.setString('organizationId', userData['organization']);
            } else if (userData['organization'] is Map &&
                userData['organization']['_id'] != null) {
              await prefs.setString(
                  'organizationId', userData['organization']['_id']);
            }
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
      print('❌ Error saving auth data: $e');
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
          'userType':
              userType.toString().split('.').last, // Convert enum to string
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['data']['accessToken'];

        if (newAccessToken != null) {
          await prefs.setString('accessToken', newAccessToken);

          return {'success': true, 'message': 'Token refreshed successfully'};
        }
      }

      return {'success': false, 'message': 'Failed to refresh token'};
    } catch (e) {
      print('Error refreshing token: $e');
      return {'success': false, 'message': 'Error refreshing token: $e'};
    }
  }
}