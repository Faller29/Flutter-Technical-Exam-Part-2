class ApiConstants {
  // Base URL - Change based on your environment
  static const String baseUrl = 'http://localhost/flutter-jwt/api';

  // Endpoints
  static const String loginEndpoint = '$baseUrl/login.php';
  static const String profileEndpoint = '$baseUrl/get_profile.php';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
