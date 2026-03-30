import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'session_cache.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:5000';
  // 10.0.2.2 = Android emulator loopback to host machine localhost
  // Change to your actual server IP for real device testing

  static const Duration _timeout = Duration(seconds: 10);

  // ── internal: build headers ──────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'accept': '*/*',
    };
    if (auth) {
      final token = SessionCache.getJson(SessionCache.kAuthToken) as String?;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ── public HTTP helpers ──────────────────────────────────────────────────

  /// POST without auth (login, register, refresh)
  static Future<Map<String, dynamic>> postPublic(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _execute(() async {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(auth: false),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _parse(response);
    });
  }

  /// POST with auth — auto-refreshes token on 401
  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _withRefresh(() async {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _parse(response);
    });
  }

  /// GET with auth — auto-refreshes token on 401
  static Future<Map<String, dynamic>> get(String path) async {
    return _withRefresh(() async {
      final response = await http
          .get(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(),
          )
          .timeout(_timeout);
      return _parse(response);
    });
  }

  /// PUT with auth — auto-refreshes token on 401
  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _withRefresh(() async {
      final response = await http
          .put(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _parse(response);
    });
  }

  // ── internals ────────────────────────────────────────────────────────────

  /// Parse HTTP response → Map. Throws [ApiException] on non-2xx.
  static Map<String, dynamic> _parse(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(response.statusCode, 'Invalid JSON response');
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final msg = (body['message'] as String?) ?? 'Unknown error';
    throw ApiException(response.statusCode, msg);
  }

  /// Wraps a call; on 401 attempts one token refresh then retries.
  static Future<Map<String, dynamic>> _withRefresh(
    Future<Map<String, dynamic>> Function() call,
  ) async {
    return _execute(() async {
      try {
        return await call();
      } on ApiException catch (e) {
        if (e.statusCode == 401) {
          final refreshed = await _tryRefresh();
          if (refreshed) return await call();
          // Refresh failed — caller should handle logout
          rethrow;
        }
        rethrow;
      }
    });
  }

  /// Attempt to refresh the access token using the stored refresh token.
  /// Returns true on success, false if refresh token is missing/expired.
  static Future<bool> _tryRefresh() async {
    final refreshToken =
        SessionCache.getJson(SessionCache.kRefreshToken) as String?;
    if (refreshToken == null || refreshToken.isEmpty) return false;

    final expiredAtStr =
        SessionCache.getJson(SessionCache.kRefreshTokenExpiredAt) as String?;
    if (expiredAtStr != null) {
      try {
        final expiredAt = DateTime.parse(expiredAtStr);
        if (DateTime.now().isAfter(expiredAt)) return false;
      } catch (_) {
        // ignore parse error, try refresh anyway
      }
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/refresh'),
            headers: {'Content-Type': 'application/json', 'accept': '*/*'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        await SessionCache.setJson(
            SessionCache.kAuthToken, data['token'] ?? '');
        await SessionCache.setJson(
            SessionCache.kRefreshToken, data['refreshToken'] ?? '');
        await SessionCache.setJson(SessionCache.kRefreshTokenExpiredAt,
            data['refreshTokenExpiredAt'] ?? '');
        return true;
      }
    } catch (_) {
      // Network error during refresh — not catastrophic, return false
    }
    return false;
  }

  /// Top-level guard: maps common exceptions to [ApiException].
  static Future<Map<String, dynamic>> _execute(
    Future<Map<String, dynamic>> Function() call,
  ) async {
    try {
      return await call();
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(0, 'Không có kết nối mạng');
    } on HttpException {
      throw const ApiException(0, 'Lỗi kết nối máy chủ');
    } on FormatException {
      throw const ApiException(0, 'Dữ liệu không hợp lệ');
    } catch (e) {
      throw ApiException(0, 'Lỗi không xác định: $e');
    }
  }
}
