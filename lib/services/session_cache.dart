import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Key-value cache backed by SharedPreferences.
/// All session data is wiped when 30 minutes have passed since the last write.
/// Non-session prefs (settings, onboarding flag) are preserved.
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
    await _touch();
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

  static Future<void> clearSession() async {
    final p = await _p;
    const preserve = {
      'seen_onboarding',
      'dark_mode',
      'push_notifs',
      'order_notifs',
      'promo_notifs',
      'email_notifs',
    };
    final toRemove = p.getKeys().where((k) => !preserve.contains(k)).toList();
    for (final k in toRemove) {
      await p.remove(k);
    }
  }

  static const kCart = 'session_cart';
  static const kWishlist = 'session_wishlist';
  static const kOrders = 'session_orders';
  static const kUser = 'session_user';
  static const kLoyaltyPoints = 'session_loyalty_points';
}
