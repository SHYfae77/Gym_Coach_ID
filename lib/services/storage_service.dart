import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveJson(String key, Object value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, jsonEncode(value));
  }

  static Future<String?> loadString(String key) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(key);
  }
}
