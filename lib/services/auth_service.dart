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
  // Used when the API is unreachable. Matches the old hardcoded map in
  // login_screen.dart so demo always works.
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

  /// Attempts real API login; falls back to mock on network error.
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

      // Persist tokens
      await _saveTokens(data);

      final user = UserModel(
        accountId: _safeInt(data['accountId']),
        username: _safeStr(data['username']),
        name: _safeStr(data['username']), // API login doesn't return full name
        email: '',
        phone: phone.trim(),
        city: '',
        role: _safeInt(data['role']),
        joinedAt: DateTime.now(),
      );

      await SessionCache.setJson(SessionCache.kUser, _userToJson(user));
      return AuthResult.success(user);
    } on ApiException catch (e) {
      // 401 = wrong credentials — real error, do NOT fall back to mock
      if (e.statusCode == 401 || e.statusCode == 400) {
        return const AuthResult.failure(
            'Số điện thoại hoặc mật khẩu không đúng');
      }
      // Network / server error → fall back to mock
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

  /// Attempts real API register; falls back to mock success on network error.
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
        role: 2, // CUSTOMER
        joinedAt: _safeDate(data?['createdDate']),
        avatarUrl: data?['avatarUrl'] as String?,
      );

      return AuthResult.success(user);
    } on ApiException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 409) {
        // 409 = phone already exists; 400 = validation error
        return AuthResult.failure(e.message);
      }
      // Network / server error → mock success for demo
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

  // ── Safe JSON helpers (guards against unexpected API shapes) ──────────────

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
