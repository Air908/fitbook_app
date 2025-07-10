import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static SharedPreferences? _prefs;

  // Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyUserRole = 'user_role';
  static const String keyAvatarUrl = 'avatar_url';
  static const String keyAuthToken = 'auth_token';

  /// Ensure SharedPreferences is initialized
  static Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Set value based on type (auto-initialize)
  static Future<void> setValue<T>(String key, T value) async {
    await _ensureInitialized();

    if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    } else if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is List<String>) {
      await _prefs!.setStringList(key, value);
    } else {
      throw Exception('Unsupported value type: $T');
    }
  }

  /// Get value with default fallback (auto-initialize)
  static Future<T?> getValue<T>(String key, {T? defaultValue}) async {
    await _ensureInitialized();

    final value = _prefs!.get(key);
    if (value is T) return value;
    return defaultValue;
  }

  /// Remove key (auto-initialize)
  static Future<void> remove(String key) async {
    await _ensureInitialized();
    await _prefs!.remove(key);
  }

  /// Clear all (auto-initialize)
  static Future<void> clear() async {
    await _ensureInitialized();
    await _prefs!.clear();
  }
}
