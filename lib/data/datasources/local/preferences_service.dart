import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService();

  Future<void> setJson(String key, Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(value));
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(key);
    if (s == null) return null;
    return json.decode(s) as Map<String, dynamic>;
  }
}
