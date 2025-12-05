/// API Configuration
class ApiConfig {
  // ==================== BASE URLS ====================

  /// Development URL (local/test)
  static const String devBaseUrl = "http://192.168.1.11:8000";

  // /// Production URL (deploy lên server thật)
  // static const String prodBaseUrl = "https://api.yourdomain.com";

  /// Current base URL (đổi khi deploy)
  static const String baseUrl = devBaseUrl; // ← Change to prodBaseUrl when deploying

  // ==================== ENDPOINTS ====================

  /// Acne detection
  static const String acneDetect = "/acne/detect";
  static const String acneHistory = "/acne/history";
  static const String acneStats = "/acne/statistics";

  ///auth
  static const String authRegister= "/users/register";
  static const String authResent= "/users/resend-confirmation";
  static const String authLogin = "/users/login";
  static const String authForgot ="/users/forgot-password";
  static const String authReset = "/users/reset-password";

  /// GET /users/
  static const String usersList = "/users/";

  /// GET /users/{id}
  static const String usersGetById = "/users";

  /// PUT /users/{id}
  static const String usersUpdate = "/users";

  /// DELETE /users/{id}
  static const String usersDelete = "/users";



  // ==================== HELPERS ====================

  /// Get full URL
  static String getUrl(String endpoint) => '$baseUrl$endpoint';

  static String getUrlWithId(String endpoint, String id) {
    return '$baseUrl$endpoint/$id';
  }
  //     getUrlWithId("/users/profile", "123")
  //     → "http://192.168.1.11:8000/users/profile/123"

  static Map<String, String> getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
  /// Timeout durations
  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
}