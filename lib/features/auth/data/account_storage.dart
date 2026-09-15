import 'package:shared_preferences/shared_preferences.dart';

class AccountStorage {
  static const _loggedInKey = 'account_logged_in';
  static const _emailKey = 'account_email';

  static Future<void> saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_emailKey, email);
  }

  static Future<void> markLoggedIn({String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    if (email != null) await prefs.setString(_emailKey, email);
  }

  static Future<bool> readLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  static Future<String?> readEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
    await prefs.remove(_emailKey);
  }
}
