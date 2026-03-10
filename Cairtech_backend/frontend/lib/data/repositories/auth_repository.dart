import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  /// Login with email and password. Returns JWT token.
  Future<String> login(String email, String password) async {
    final response = await _apiService.get(
      ApiConstants.login,
      queryParameters: {'email': email, 'password': password},
    );
    final token = response.data as String;
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
    final token = response.data as String;
    await _apiService.saveToken(token);
    return token;
  }

  /// Logout: clear stored token
  Future<void> logout() async {
    await _apiService.clearToken();
  }
}
