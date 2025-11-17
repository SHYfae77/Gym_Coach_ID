// lib/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _kUserKey = 'auth_user_v1';

  // Struktur data yang kita simpan (simple)
  // { "email": "...", "xp": 420, "workouts": 24, "streak": 5 }
  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  static Future<bool> login(String email, String pass) async {
    // sederhana: jika email/password non-empty, simulasikan sukses
    if (email.isEmpty || pass.isEmpty) return false;
    final prefs = await _prefs();

    // jika belum ada user tersimpan, buat user baru "local" (auto-register)
    final raw = prefs.getString(_kUserKey);
    if (raw == null) {
      final user = {
        'email': email,
        'xp': 420,
        'workouts': 24,
        'streak': 5,
      };
      await prefs.setString(_kUserKey, jsonEncode(user));
      return true;
    } else {
      // jika ada user, cek email cocok (kita abaikan password pada mock)
      final m = jsonDecode(raw) as Map<String, dynamic>;
      if ((m['email'] as String?) == email) {
        return true;
      } else {
        // tidak cocok -> treat as failed login (atau otomatis register, pilih salah satu)
        return false;
      }
    }
  }

  static Future<bool> register(String email, String pass) async {
    if (email.isEmpty || pass.isEmpty) return false;
    final prefs = await _prefs();
    final user = {
      'email': email,
      'xp': 0,
      'workouts': 0,
      'streak': 0,
    };
    await prefs.setString(_kUserKey, jsonEncode(user));
    return true;
  }

  // Google sign-in mock: hanya buat user contoh
  static Future<bool> signInWithGoogle() async {
    final prefs = await _prefs();
    final user = {
      'email': 'google.user@example.com',
      'xp': 800,
      'workouts': 40,
      'streak': 12,
    };
    await prefs.setString(_kUserKey, jsonEncode(user));
    return true;
  }

  static Future<void> logout() async {
    final prefs = await _prefs();
    await prefs.remove(_kUserKey);
  }

  static Future<bool> isLoggedIn() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool('logged_in') ?? false;
  }

  static Future<String?> getUserEmail() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_kUserKey);
    if (raw == null) return null;
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return m['email'] as String?;
  }

  static Future<int> getUserXP() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_kUserKey);
    if (raw == null) return 0;
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return (m['xp'] as num).toInt();
  }

  static Future<int> getUserWorkouts() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_kUserKey);
    if (raw == null) return 0;
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return (m['workouts'] as num).toInt();
  }

  static Future<int> getUserStreak() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_kUserKey);
    if (raw == null) return 0;
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return (m['streak'] as num).toInt();
  }
}
