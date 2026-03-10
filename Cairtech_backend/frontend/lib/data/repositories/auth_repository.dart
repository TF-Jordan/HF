import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  /// Extract token from response, handling both plain text and JSON-quoted strings
  String _extractToken(dynamic data) {
    String token = data.toString().trim();
    // Remove surrounding quotes if present (WebFlux JSON-serialized String)
    if (token.startsWith('"') && token.endsWith('"')) {
      token = token.substring(1, token.length - 1);
    }
    return token;
  }

  /// Login with email and password. Returns JWT token.
  Future<String> login(String email, String password) async {
    final response = await _apiService.get(
      ApiConstants.login,
      queryParameters: {'email': email, 'password': password},
    );
    final token = _extractToken(response.data);
    await _apiService.saveToken(token);
    return token;
  }

  /// Register a new user. Returns JWT token.
  Future<String> register({
    required String email,
    required String password,
    required String phoneNumber,
    String status = 'ACTIVE',
  }) async {
    final response = await _apiService.post(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'status': status,
      },
    );
    final token = _extractToken(response.data);
    await _apiService.saveToken(token);
    return token;
  }

  /// Logout: clear stored token
  Future<void> logout() async {
    await _apiService.clearToken();
  }
}
