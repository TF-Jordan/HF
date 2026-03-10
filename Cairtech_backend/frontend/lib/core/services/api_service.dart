import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';

  /// In-memory fallback if FlutterSecureStorage fails (e.g. Linux without libsecret)
  String? _memoryToken;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            clearToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ── Token Management ──────────────────────────────────────

  Future<void> saveToken(String token) async {
    _memoryToken = token;
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {
      // SecureStorage unavailable (Linux without libsecret, etc.)
      // Token is still stored in memory
    }
  }

  Future<String?> getToken() async {
    try {
      final stored = await _storage.read(key: _tokenKey);
      if (stored != null) {
        _memoryToken = stored;
        return stored;
      }
    } catch (_) {
      // SecureStorage unavailable, use memory fallback
    }
    return _memoryToken;
  }

  Future<void> clearToken() async {
    _memoryToken = null;
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {
      // SecureStorage unavailable
    }
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── HTTP Methods ──────────────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    return _dio.put(path, data: data);
  }

  Future<Response> patch(
    String path, {
    dynamic data,
  }) async {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
}
