import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Get the appropriate base URL based on platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';  // For web
    } else if (Platform.isAndroid) {
      // 10.0.2.2 is the special IP for Android emulators to access host machine
      return 'http://10.0.2.2:8000';  // For Android emulator
      
      // If using a physical device, uncomment this line and use your computer's IP:
      // return 'http://192.168.X.X:8000';  // Replace X.X with your actual IP
    } else {
      return 'http://localhost:8000';  // For iOS simulator and other platforms
    }
  }
  
  
  // Admin routes
  static String get adminRegisterCoach => '$baseUrl/api/v1/admins/register-coach';
  static String get adminLogin => '$baseUrl/api/v1/admins/login';
  
  // Coach routes
  static String get coachLogin => '$baseUrl/api/v1/coaches/login';
  
  // Athlete routes
  static String get athleteLogin => '$baseUrl/api/v1/athletes/login';
  static String get independentAthleteLogin => '$baseUrl/api/v1/independent-athletes/login';
  
  // Sponsor routes
  static String get sponsorLogin => '$baseUrl/api/v1/sponsors/login';
  
  // Other common routes
  static String get refreshToken => '$baseUrl/api/v1/refresh';
  
  // Health check endpoint for testing connection
  static String get healthCheck => '$baseUrl/api/v1/health';
}