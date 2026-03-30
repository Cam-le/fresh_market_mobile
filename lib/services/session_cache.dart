import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Key-value cache backed by SharedPreferences.
/// All session data is wiped when 30 minutes have passed since the last write.
/// Non-session prefs (settings, onboarding flag, auth tokens) are preserved.
class SessionCache {
  static const _tsKey = '_session_last_write';
  static const _sessionDuration = Duration(minutes: 30);

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _p async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Call once at app startup. Wipes session data if the session has expired.
  static Future<void> init() async {
    final p = await _p;
    final lastWrite = p.getInt(_tsKey);
    if (lastWrite != null) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - lastWrite;
      if (elapsed > _sessionDuration.inMilliseconds) {
        await clearSession();
      }
    }
  }

  static Future<void> _touch() async {
    final p = await _p;
    await p.setInt(_tsKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> setJson(String key, Object data) async {
    final p = await _p;
    await p.setString(key, jsonEncode(data));
    // Don't touch the session timestamp for auth keys — auth tokens should
    // survive the 30-min session window independently.
    if (!_authKeys.contains(key)) await _touch();
  }

  static dynamic getJson(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  /// Wipes cart/wishlist/orders/user/loyalty — preserves settings & auth tokens.
  static Future<void> clearSession() async {
    final p = await _p;
    final toRemove =
        p.getKeys().where((k) => !_preservedKeys.contains(k)).toList();
    for (final k in toRemove) {
      await p.remove(k);
    }
  }

  /// Clears auth tokens only (used on logout).
  static Future<void> clearAuth() async {
    final p = await _p;
    for (final k in _authKeys) {
      await p.remove(k);
    }
  }

  // ── Session keys (wiped after 30 min idle) ────────────────────────────────
  static const kCart = 'session_cart';
  static const kWishlist = 'session_wishlist';
  static const kOrders = 'session_orders';
  static const kUser = 'session_user';
  static const kLoyaltyPoints = 'session_loyalty_points';

  // ── Auth keys (persisted across sessions, cleared only on logout) ─────────
  static const kAuthToken = 'auth_token';
  static const kRefreshToken = 'auth_refresh_token';
  static const kRefreshTokenExpiredAt = 'auth_refresh_token_expired_at';

  static const _authKeys = {
    kAuthToken,
    kRefreshToken,
    kRefreshTokenExpiredAt,
  };

  static const _preservedKeys = {
    // Settings — never wiped
    'seen_onboarding',
    'dark_mode',
    'push_notifs',
    'order_notifs',
    'promo_notifs',
    'email_notifs',
    // Auth — cleared only on explicit logout
    kAuthToken,
    kRefreshToken,
    kRefreshTokenExpiredAt,
  };
}
