import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  /// Decode the stored JWT and extract user info
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await _apiService.getToken();
    if (token == null || JwtDecoder.isExpired(token)) {
      return null;
    }
    return JwtDecoder.decode(token);
  }

  /// Extract roles from JWT claims
  Future<List<String>> getUserRoles() async {
    final claims = await getCurrentUser();
    if (claims == null) return [];
    final roles = claims['roles'];
    if (roles is List) {
      return roles.cast<String>();
    }
    return [];
  }

  /// Check if user has a specific role
  Future<bool> hasRole(String role) async {
    final roles = await getUserRoles();
    return roles.contains(role);
  }

  /// Check if token is valid and not expired
  Future<bool> isAuthenticated() async {
    final token = await _apiService.getToken();
    if (token == null) return false;
    return !JwtDecoder.isExpired(token);
  }

  /// Logout: clear stored token
  Future<void> logout() async {
    await _apiService.clearToken();
  }
}
