class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://localhost:8000';
  
  // Admin routes
  static const String adminRegisterCoach = '$baseUrl/api/v1/admins/register-coach';
  static const String adminLogin = '$baseUrl/api/v1/admins/login';
  
  // Coach routes
  static const String coachLogin = '$baseUrl/api/v1/coaches/login';
  
  // Athlete routes
  static const String athleteLogin = '$baseUrl/api/v1/athletes/login';
  static const String independentAthleteLogin = '$baseUrl/api/v1/athletes/login-independent';
  
  // Sponsor routes
  static const String sponsorLogin = '$baseUrl/api/v1/sponsors/login';
  
  // Other common routes
  static const String refreshToken = '$baseUrl/api/v1/refresh';
}