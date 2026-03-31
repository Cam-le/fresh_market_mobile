import 'dart:convert';
import '../models/user.dart';
import 'api_client.dart';
import 'session_cache.dart';

/// Result wrapper so callers get either data or an error message —
/// never an unhandled exception.
class AuthResult<T> {
  final T? data;
  final String? error;
  final bool fromMock;

  const AuthResult.success(this.data, {this.fromMock = false}) : error = null;
  const AuthResult.failure(this.error)
      : data = null,
        fromMock = false;

  bool get isSuccess => error == null;
}

class AuthService {
  // ── Mock fallback accounts ────────────────────────────────────────────────
  static const _mockAccounts = {
    '0961231158': '123456',
    '0123456789': '123456',
  };

  static UserModel get _mockUser => UserModel(
        accountId: 0,
        username: 'demo_user',
        name: 'Người Dùng Demo',
        email: '',
        phone: '0961231158',
        city: 'Hồ Chí Minh',
        role: 2,
        joinedAt: DateTime(2026, 1, 1),
      );

  // ── Login ─────────────────────────────────────────────────────────────────

  static Future<AuthResult<UserModel>> login(
      String phone, String password) async {
    try {
      final response = await ApiClient.postPublic('/auth/login', {
        'phone': phone.trim(),
        'password': password,
      });

      if (response['success'] != true) {
        final msg = (response['message'] as String?) ?? 'Đăng nhập thất bại';
        return AuthResult.failure(msg);
      }

      final data = _safeMap(response['data']);
      if (data == null) {
        return const AuthResult.failure('Dữ liệu phản hồi không hợp lệ');
      }

      await _saveTokens(data);

      // accountId is NOT returned by login endpoint — decode from JWT 'sub' claim
      final token = _safeStr(data['token']);
      final jwtPayload = _decodeJwtPayload(token);
      final accountId = _safeInt(jwtPayload['sub'] ?? jwtPayload['accountId']);
      final phoneFromJwt =
          _safeStr(jwtPayload['phone'], fallback: phone.trim());

      final user = UserModel(
        accountId: accountId,
        username: _safeStr(data['username']),
        name: _safeStr(data['username']),
        email: '',
        phone: phoneFromJwt.isNotEmpty ? phoneFromJwt : phone.trim(),
        city: '',
        role: _safeInt(data['role']),
        joinedAt: DateTime.now(),
      );

      await SessionCache.setJson(SessionCache.kUser, _userToJson(user));
      return AuthResult.success(user);
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 400) {
        return const AuthResult.failure(
            'Số điện thoại hoặc mật khẩu không đúng');
      }
      return _mockLogin(phone, password);
    } catch (_) {
      return _mockLogin(phone, password);
    }
  }

  static AuthResult<UserModel> _mockLogin(String phone, String password) {
    final stored = _mockAccounts[phone.trim()];
    if (stored != null && stored == password) {
      return AuthResult.success(
        _mockUser.copyWith(phone: phone.trim()),
        fromMock: true,
      );
    }
    return const AuthResult.failure('Số điện thoại hoặc mật khẩu không đúng');
  }

  // ── Register ──────────────────────────────────────────────────────────────

  static Future<AuthResult<UserModel>> register(
      String phone, String password) async {
    try {
      final response = await ApiClient.postPublic('/auth/register', {
        'phone': phone.trim(),
        'password': password,
      });

      final isSuccess = response['success'] == true ||
          (response['statusCode'] != null &&
              (response['statusCode'] as int) >= 200 &&
              (response['statusCode'] as int) < 300);

      if (!isSuccess) {
        final msg = (response['message'] as String?) ?? 'Đăng ký thất bại';
        return AuthResult.failure(msg);
      }

      final data = _safeMap(response['data']);

      final user = UserModel(
        accountId: _safeInt(data?['accountId']),
        username: _safeStr(data?['username']),
        name: _safeStr(data?['username']),
        email: _safeStr(data?['email']),
        phone: _safeStr(data?['phone'], fallback: phone.trim()),
        city: '',
        role: 2,
        joinedAt: _safeDate(data?['createdDate']),
        avatarUrl: data?['avatarUrl'] as String?,
      );

      return AuthResult.success(user);
    } on ApiException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 409) {
        return AuthResult.failure(e.message);
      }
      return AuthResult.success(
        UserModel(
          accountId: 0,
          username: 'user_demo',
          name: '',
          email: '',
          phone: phone.trim(),
          city: '',
          role: 2,
          joinedAt: DateTime.now(),
        ),
        fromMock: true,
      );
    } catch (_) {
      return AuthResult.success(
        UserModel(
          accountId: 0,
          username: 'user_demo',
          name: '',
          email: '',
          phone: phone.trim(),
          city: '',
          role: 2,
          joinedAt: DateTime.now(),
        ),
        fromMock: true,
      );
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  static Future<void> logout() async {
    await SessionCache.clearSession();
  }

  // ── Token helpers ─────────────────────────────────────────────────────────

  static bool get isLoggedIn {
    final token = SessionCache.getJson(SessionCache.kAuthToken) as String?;
    return token != null && token.isNotEmpty;
  }

  static Future<void> _saveTokens(Map<String, dynamic> data) async {
    await SessionCache.setJson(SessionCache.kAuthToken, data['token'] ?? '');
    await SessionCache.setJson(
        SessionCache.kRefreshToken, data['refreshToken'] ?? '');
    await SessionCache.setJson(SessionCache.kRefreshTokenExpiredAt,
        data['refreshTokenExpiredAt'] ?? '');
  }

  // ── JWT decoder ───────────────────────────────────────────────────────────

  /// Decodes the payload section of a JWT without verifying the signature.
  /// Returns an empty map on any parse failure — never throws.
  static Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      // JWT uses base64url — pad to a multiple of 4
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final decoded = utf8.decode(base64Decode(payload));
      final json = jsonDecode(decoded);
      if (json is Map<String, dynamic>) return json;
      return {};
    } catch (_) {
      return {};
    }
  }

  // ── Safe JSON helpers ─────────────────────────────────────────────────────

  static Map<String, dynamic>? _safeMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    return null;
  }

  static int _safeInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static String _safeStr(dynamic v, {String fallback = ''}) {
    if (v is String) return v;
    return fallback;
  }

  static DateTime _safeDate(dynamic v) {
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  static Map<String, dynamic> _userToJson(UserModel u) => {
        'accountId': u.accountId,
        'username': u.username,
        'name': u.name,
        'email': u.email,
        'phone': u.phone,
        'city': u.city,
        'role': u.role,
        'avatarUrl': u.avatarUrl,
        'joinedAt': u.joinedAt.toIso8601String(),
      };
}
