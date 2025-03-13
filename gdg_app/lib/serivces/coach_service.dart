import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class CoachService {
  final String baseUrl = ApiConstants.baseUrl;
  
  Future<Map<String, dynamic>> registerCoach({
    required String name,
    required String email,
    required String password,
    required String dob,
    required String gender,
    required String nationality,
    required String contactNumber,
    required String address,
    required String state,
    required String country,
    required String sport,
    required String experience,
    required String certifications,
    required String previousOrganizations,
    String? designation,
    File? profilePhoto,
    File? idProof,
    File? certificatesFile,
  }) async {
    try {
      // Get the admin token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token not found. Please log in again.'
        };
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/coaches/register-coach'),
      );
      
      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      
      // Add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['dob'] = dob;
      request.fields['gender'] = gender;
      request.fields['nationality'] = nationality;
      request.fields['contactNumber'] = contactNumber;
      request.fields['address'] = address;
      request.fields['state'] = state;
      request.fields['country'] = country;
      request.fields['sport'] = sport;
      request.fields['experience'] = experience;
      request.fields['certifications'] = certifications;
      request.fields['previousOrganizations'] = previousOrganizations;
      
      // Get organization ID from stored preferences
      String? organizationId = prefs.getString('organizationId');
      if (organizationId != null && organizationId.isNotEmpty) {
        request.fields['organizationId'] = organizationId;
      } else {
        // Handle case where organizationId is not available
        // You might want to fetch it first or return an error
        return {
          'success': false,
          'message': 'Organization ID not found. Please log in again.'
        };
      }
      
      if (designation != null && designation.isNotEmpty) {
        request.fields['designation'] = designation;
      }
      
      // Add file fields if they exist
      if (profilePhoto != null) {
        var profilePhotoStream = http.ByteStream(profilePhoto.openRead());
        var profilePhotoLength = await profilePhoto.length();
        
        var profilePhotoMultipart = http.MultipartFile(
          'profilePhoto',
          profilePhotoStream,
          profilePhotoLength,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        request.files.add(profilePhotoMultipart);
      }
      
      if (idProof != null) {
        var idProofStream = http.ByteStream(idProof.openRead());
        var idProofLength = await idProof.length();
        
        var idProofMultipart = http.MultipartFile(
          'idProof',
          idProofStream,
          idProofLength,
          filename: 'id_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        request.files.add(idProofMultipart);
      }
      
      if (certificatesFile != null) {
        var certificatesStream = http.ByteStream(certificatesFile.openRead());
        var certificatesLength = await certificatesFile.length();
        
        var certificatesMultipart = http.MultipartFile(
          'certificates',
          certificatesStream,
          certificatesLength,
          filename: 'cert_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        request.files.add(certificatesMultipart);
      }
      
      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      // Parse the response
      Map<String, dynamic> responseData = json.decode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Coach registered successfully',
          'data': responseData['data'] ?? {}
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to register coach'
        };
      }
    } catch (e) {
      print('Error registering coach: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}'
      };
    }
  }
}