// services/cache_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static const String _facilitiesKey = 'cached_facilities';
  static const Duration _cacheDuration = Duration(minutes: 15);

  static Future<void> cacheFacilities(List<Map<String, dynamic>> facilities) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': facilities,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_facilitiesKey, jsonEncode(cacheData));
  }

  static Future<List<Map<String, dynamic>>?> getCachedFacilities() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(_facilitiesKey);

    if (cachedString != null) {
      final cacheData = jsonDecode(cachedString);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);

      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        return List<Map<String, dynamic>>.from(cacheData['data']);
      }
    }

    return null;
  }
}