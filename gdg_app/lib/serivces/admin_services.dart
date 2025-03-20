import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:http_parser/http_parser.dart';
import 'package:gdg_app/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  // Get authentication token from shared preferences
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    
    return {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }
  
  // Register a new admin
  Future<Map<String, dynamic>> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String role,
    File? avatarFile,
  }) async {
    try {
      // Get organization ID from shared preferences (stored during admin login)
      final prefs = await SharedPreferences.getInstance();
      final organizationId = prefs.getString('organizationId');
      
      if (organizationId == null) {
        return {
          'success': false,
          'message': 'Organization ID not found. Please log in again.',
        };
      }
      
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/admins/register');
      
      // Create multipart request for avatar upload
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      final headers = await _getHeaders();
      request.headers.addAll(headers);
      
      // Add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['organizationId'] = organizationId;
      request.fields['role'] = role;
      
      // Add avatar file if provided
      if (avatarFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            avatarFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('Register admin response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'admin': data['admin'],
          'message': data['message'] ?? 'Admin registered successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to register admin',
        };
      }
    } catch (e) {
      debugPrint('Error registering admin: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }
  
  // Get all admins with pagination and filtering
  Future<Map<String, dynamic>> getAllAdmins({
    int page = 1,
    int limit = 10,
    String sort = 'name',
    String order = 'asc',
    String search = '',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
        'order': order,
        if (search.isNotEmpty) 'search': search,
      };
      
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/admins/administrators')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      debugPrint('Get admins response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'admins': data['data']['admins'] ?? [],
          'pagination': data['data']['pagination'] ?? {},
          'message': data['message'] ?? 'Administrators fetched successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to fetch administrators',
        };
      }
    } catch (e) {
      debugPrint('Error fetching admins: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

    // Method to get all coaches with pagination and filtering
  Future<Map<String, dynamic>> getAllCoaches({
    int page = 1,
    int limit = 10,
    String sort = 'name',
    String order = 'asc',
    String search = '',
    String sport = '',
    String designation = '',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
        'order': order,
        if (search.isNotEmpty) 'search': search,
        if (sport.isNotEmpty && sport != 'All') 'sport': sport,
        if (designation.isNotEmpty && designation != 'All') 'designation': designation,
      };
      
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/admins/coaches')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      debugPrint('Get coaches response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'coaches': data['data']['coaches'] ?? [],
          'pagination': data['data']['pagination'] ?? {},
          'message': data['message'] ?? 'Coaches fetched successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to fetch coaches',
        };
      }
    } catch (e) {
      debugPrint('Error fetching coaches: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }
  
  // Register a new coach with complete details
  Future<Map<String, dynamic>> registerCoach({
    required String name,
    required String email,
    required String password,
    required String dob,
    required String gender,
    required String nationality,
    required String contactNumber,
    required String address,
    String? city,
    required String state,
    required String country,
    String? pincode,
    required String sport,
    required String experience,
    required String certifications,
    String? previousOrganizations,
    required String designation,
    File? profilePhoto,
    File? idProof,
    File? certificatesFile,
  }) async {
    try {

      // Get organization ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final organizationId = prefs.getString('organizationId');
      
      if (organizationId == null) {
        return {
          'success': false,
          'message': 'Organization ID not found. Please log in again.',
        };
      }
      
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/admins/register-coach');
      
      // Create multipart request for file uploads
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers for multipart request
final headers = await _getHeaders();
// Remove Content-Type as it will be set automatically for multipart requests
headers.remove('Content-Type');
// Add Accept header
headers['Accept'] = 'application/json';
request.headers.addAll(headers);
      
      // Add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['organizationId'] = organizationId;
      request.fields['dob'] = dob;
      request.fields['gender'] = gender;
      request.fields['nationality'] = nationality;
      request.fields['contactNumber'] = contactNumber;
      request.fields['address'] = address;
      if (city != null) request.fields['city'] = city;
      request.fields['state'] = state;
      request.fields['country'] = country;
      if (pincode != null) request.fields['pincode'] = pincode;
      request.fields['sport'] = sport;
      request.fields['experience'] = experience;
      request.fields['certifications'] = certifications;
      if (previousOrganizations != null) {
        request.fields['previousOrganizations'] = previousOrganizations;
      }
      request.fields['designation'] = designation;
      
      // Add files if provided
      // Add files if provided
if (profilePhoto != null) {
  String fileExt = profilePhoto.path.split('.').last.toLowerCase();
  MediaType contentType;
  
  if (fileExt == 'png') {
    contentType = MediaType('image', 'png');
  } else if (fileExt == 'jpg' || fileExt == 'jpeg') {
    contentType = MediaType('image', 'jpeg');
  } else {
    contentType = MediaType('image', 'jpeg'); // Default
  }
  
  request.files.add(
    await http.MultipartFile.fromPath(
      'profilePhoto',
      profilePhoto.path,
      contentType: contentType,
    ),
  );
}

if (idProof != null) {
  String fileExt = idProof.path.split('.').last.toLowerCase();
  MediaType contentType;
  
  if (fileExt == 'pdf') {
    contentType = MediaType('application', 'pdf');
  } else if (fileExt == 'png') {
    contentType = MediaType('image', 'png');
  } else if (fileExt == 'jpg' || fileExt == 'jpeg') {
    contentType = MediaType('image', 'jpeg');
  } else {
    contentType = MediaType('image', 'jpeg'); // Default
  }
  
  request.files.add(
    await http.MultipartFile.fromPath(
      'idProof',
      idProof.path,
      contentType: contentType,
    ),
  );
}

if (certificatesFile != null) {
  String fileExt = certificatesFile.path.split('.').last.toLowerCase();
  MediaType contentType;
  
  if (fileExt == 'pdf') {
    contentType = MediaType('application', 'pdf');
  } else if (fileExt == 'png') {
    contentType = MediaType('image', 'png');
  } else if (fileExt == 'jpg' || fileExt == 'jpeg') {
    contentType = MediaType('image', 'jpeg');
  } else {
    contentType = MediaType('application', 'pdf'); // Default
  }
  
  request.files.add(
    await http.MultipartFile.fromPath(
      'certificates',
      certificatesFile.path,
      contentType: contentType,
    ),
  );
}
      
      debugPrint('Sending coach registration request to: ${uri.toString()}');
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('Register coach response status: ${response.statusCode}');
      if (response.body.isNotEmpty) {
        debugPrint('Response body: ${response.body.substring(0, min(300, response.body.length))}');
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'coach': data['coach'],
          'message': data['message'] ?? 'Coach registered successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to register coach',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      debugPrint('Error registering coach: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }


Future<Map<String, dynamic>> registerAthlete({
  required String name,
  required String dob,
  required String gender,
  required String nationality,
  required String address,
  required String phoneNumber,
  required String schoolName,
  required String year,
  required String studentId,
  String? schoolEmail,
  String? schoolWebsite,
  required List<String> sports,
  required String skillLevel,
  required String trainingStartDate,
  Map<String, String>? positions,
  String? dominantHand,
  String? headCoachAssigned,
  String? gymTrainerAssigned,
  String? medicalStaffAssigned,
  required String height,
  required String weight,
  String? bloodGroup,
  List<String>? allergies,
  List<String>? medicalConditions,
  required String emergencyContactName,
  required String emergencyContactNumber,
  required String emergencyContactRelationship,
  required String email,
  required String password,
  String? athleteId, // For updates
  File? avatarFile,
  File? schoolIdFile,
  File? marksheetFile,
}) async {
  try {
    // Get organization ID from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final organizationId = prefs.getString('organizationId');
    
    if (organizationId == null) {
      return {
        'success': false,
        'message': 'Organization ID not found. Please log in again.',
      };
    }
    
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/admins/register-organization-athlete');
    
    // Create multipart request for file uploads
    final request = http.MultipartRequest('POST', uri);
    
    // Add headers for multipart request
    final headers = await _getHeaders();
    // Remove Content-Type as it will be set automatically for multipart requests
    headers.remove('Content-Type');
    // Add Accept header
    headers['Accept'] = 'application/json';
    request.headers.addAll(headers);
    
    // Add text fields
    request.fields['name'] = name;
    request.fields['dob'] = dob;
    request.fields['gender'] = gender;
    request.fields['nationality'] = nationality;
    request.fields['address'] = address;
    request.fields['phoneNumber'] = phoneNumber;
    request.fields['schoolName'] = schoolName;
    request.fields['year'] = year;
    request.fields['studentId'] = studentId;
    if (schoolEmail != null) request.fields['schoolEmail'] = schoolEmail;
    if (schoolWebsite != null) request.fields['schoolWebsite'] = schoolWebsite;
    
    // Handle sports (can be single or list)
    if (sports.length == 1) {
      request.fields['sports'] = sports.first;
    } else {
      for (int i = 0; i < sports.length; i++) {
        request.fields['sports[$i]'] = sports[i];
      }
    }
    
    request.fields['skillLevel'] = skillLevel;
    request.fields['trainingStartDate'] = trainingStartDate;
    
    // Handle positions (map of sport to position)
    if (positions != null && positions.isNotEmpty) {
      positions.forEach((sport, position) {
        request.fields['positions[$sport]'] = position;
      });
    }
    
    if (dominantHand != null) request.fields['dominantHand'] = dominantHand;
    if (headCoachAssigned != null) request.fields['headCoachAssigned'] = headCoachAssigned;
    if (gymTrainerAssigned != null) request.fields['gymTrainerAssigned'] = gymTrainerAssigned;
    if (medicalStaffAssigned != null) request.fields['medicalStaffAssigned'] = medicalStaffAssigned;
    
    request.fields['height'] = height;
    request.fields['weight'] = weight;
    if (bloodGroup != null) request.fields['bloodGroup'] = bloodGroup;
    
    // Handle allergies list
    if (allergies != null && allergies.isNotEmpty) {
      if (allergies.length == 1) {
        request.fields['allergies'] = allergies.first;
      } else {
        for (int i = 0; i < allergies.length; i++) {
          request.fields['allergies[$i]'] = allergies[i];
        }
      }
    }
    
    // Handle medical conditions list
    if (medicalConditions != null && medicalConditions.isNotEmpty) {
      if (medicalConditions.length == 1) {
        request.fields['medicalConditions'] = medicalConditions.first;
      } else {
        for (int i = 0; i < medicalConditions.length; i++) {
          request.fields['medicalConditions[$i]'] = medicalConditions[i];
        }
      }
    }
    
    request.fields['emergencyContactName'] = emergencyContactName;
    request.fields['emergencyContactNumber'] = emergencyContactNumber;
    request.fields['emergencyContactRelationship'] = emergencyContactRelationship;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['organizationId'] = organizationId;
    
    // For updating existing athlete
    if (athleteId != null) {
      request.fields['athleteId'] = athleteId;
    }
    
    // Add files if provided
    if (avatarFile != null) {
      String fileExt = avatarFile.path.split('.').last.toLowerCase();
      MediaType contentType;
      
      if (fileExt == 'png') {
        contentType = MediaType('image', 'png');
      } else if (fileExt == 'jpg' || fileExt == 'jpeg') {
        contentType = MediaType('image', 'jpeg');
      } else {
        contentType = MediaType('image', 'jpeg'); // Default
      }
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          avatarFile.path,
          contentType: contentType,
        ),
      );
    }
    
    if (schoolIdFile != null) {
      String fileExt = schoolIdFile.path.split('.').last.toLowerCase();
      MediaType contentType;
      
      if (fileExt == 'pdf') {
        contentType = MediaType('application', 'pdf');
      } else if (fileExt == 'png') {
        contentType = MediaType('image', 'png');
      } else if (fileExt == 'jpg' || fileExt == 'jpeg') {
        contentType = MediaType('image', 'jpeg');
      } else {
        contentType = MediaType('application', 'pdf'); // Default
      }
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'uploadSchoolId',
          schoolIdFile.path,
          contentType: contentType,
        ),
      );
    }
    
    if (marksheetFile != null) {
      String fileExt = marksheetFile.path.split('.').last.toLowerCase();
      MediaType contentType;
      
      if (fileExt == 'pdf') {
        contentType = MediaType('application', 'pdf');
      } else if (fileExt == 'png') {
        contentType = MediaType('image', 'png');
      } else if (fileExt == 'jpg' || fileExt == 'jpeg') {
        contentType = MediaType('image', 'jpeg');
      } else {
        contentType = MediaType('application', 'pdf'); // Default
      }
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'latestMarksheet',
          marksheetFile.path,
          contentType: contentType,
        ),
      );
    }
    
    debugPrint('Sending athlete registration request to: ${uri.toString()}');
    
    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    debugPrint('Register athlete response status: ${response.statusCode}');
    if (response.body.isNotEmpty) {
      debugPrint('Response body: ${response.body.substring(0, min(300, response.body.length))}');
    }
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'athlete': data['data']['athlete'],
        'message': data['message'] ?? 'Athlete registered successfully',
      };
    } else {
      try {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to register athlete',
        };
      } catch (e) {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    }
  } catch (e) {
    debugPrint('Error registering athlete: $e');
    return {
      'success': false,
      'message': 'An unexpected error occurred: ${e.toString()}',
    };
  }
}


Future<Map<String, dynamic>> getAllAthletes({
  int page = 1,
  int limit = 10,
  String sort = 'name',
  String order = 'asc',
  String search = '',
  String sport = '',
  String skillLevel = '',
  String gender = '',
}) async {
  try {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'sort': sort,
      'order': order,
      if (search.isNotEmpty) 'search': search,
      if (sport.isNotEmpty && sport != 'All') 'sport': sport,
      if (skillLevel.isNotEmpty && skillLevel != 'All') 'skillLevel': skillLevel,
      if (gender.isNotEmpty && gender != 'All') 'gender': gender,
    };
    
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/admins/athletes')
        .replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );
    
    debugPrint('Get athletes response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'athletes': data['data']['athletes'] ?? [],
        'pagination': data['data']['pagination'] ?? {},
        'message': data['message'] ?? 'Athletes fetched successfully',
      };
    } else {
      final error = jsonDecode(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Failed to fetch athletes',
      };
    }
  } catch (e) {
    debugPrint('Error fetching athletes: $e');
    return {
      'success': false,
      'message': 'An unexpected error occurred: ${e.toString()}',
    };
  }
}


Future<Map<String, dynamic>> getOrganizationStats() async {
  try {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/admins/organization-stats');
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );
    
    debugPrint('Get organization stats response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'stats': data['data']['stats'] ?? {
          'adminCount': 0,
          'coachCount': 0,
          'athleteCount': 0,
          'sponsorCount': 0
        },
        'message': data['message'] ?? 'Organization statistics fetched successfully',
      };
    } else {
      final error = jsonDecode(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Failed to fetch organization statistics',
      };
    }
  } catch (e) {
    debugPrint('Error fetching organization statistics: $e');
    return {
      'success': false,
      'message': 'An unexpected error occurred: ${e.toString()}',
      'stats': {
        'adminCount': 0,
        'coachCount': 0,
        'athleteCount': 0,
        'sponsorCount': 0
      }
    };
  }
}

}