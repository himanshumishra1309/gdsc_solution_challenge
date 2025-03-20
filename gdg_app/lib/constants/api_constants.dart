import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Get the appropriate base URL based on platform
  // Replace this in api_constants.dart
static String get baseUrl {
  String url;
  if (kIsWeb) {
    url = 'http://localhost:8000';
  } else if (Platform.isAndroid) {
    // This is the critical fix - Android emulators need 10.0.2.2, not localhost
    url = 'http://localhost:8000';  // CHANGE THIS FROM localhost
  } else {
    url = 'http://localhost:8000';
  }
  
  print('API BASE URL: $url (${kIsWeb ? "Web" : Platform.operatingSystem})');
  return url;
}
  
  // Debug function to print platform details
  static void printPlatformDetails() {
    print('==== PLATFORM DETAILS ====');
    print('isWeb: $kIsWeb');
    if (!kIsWeb) {
      print('Platform: ${Platform.operatingSystem}');
      print('Version: ${Platform.operatingSystemVersion}');
      print('Is Android: ${Platform.isAndroid}');
      print('Is iOS: ${Platform.isIOS}');
    }
    print('Base URL: ${baseUrl}');
    print('========================');
  }  
  
  // Admin routes
  static String get adminRegisterCoach => '$baseUrl/api/v1/admins/register-coach';
  static String get adminLogin => '$baseUrl/api/v1/auth/admin/login';
  
  // Coach routes
  static String get coachLogin => '$baseUrl/api/v1/auth/coach/login';
  
  // Athlete routes
  static String get athleteLogin => '$baseUrl/api/v1/auth/athlete/login';
  static String get independentAthleteLogin => '$baseUrl/api/v1/independent-athletes/login';
  
  // Sponsor routes
  static String get sponsorLogin => '$baseUrl/api/v1/sponsors/login';
  
  // Other common routes
  static String get refreshToken => '$baseUrl/api/v1/refresh';
  
  // Health check endpoint for testing connection
  static String get healthCheck => '$baseUrl/api/v1/health';

  // Add these logout endpoints to your ApiConstants class
static String get adminLogout => '$baseUrl/api/v1/admins/logout';
static String get coachLogout => '$baseUrl/api/v1/coaches/logout';
static String get athleteLogout => '$baseUrl/api/v1/athletes/logout';
static String get independentAthleteLogout => '$baseUrl/api/v1/independent-athletes/logout';
static String get sponsorLogout => '$baseUrl/api/v1/sponsors/logout';
// Add these to your ApiConstants class
static String get adminRegister => '$baseUrl/api/v1/admins/register';
static String get adminGetAll => '$baseUrl/api/v1/admins/administrators';
}