import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_resturant/domain/repositories/auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  static const _emailKey = 'account_email';
  static const _passKey = 'account_password_hash';

  String _hash(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  @override
  Future<bool> isAccountCreated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_emailKey) && prefs.containsKey(_passKey);
  }

  @override
  Future<void> createAccount(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email.trim().toLowerCase());
    await prefs.setString(_passKey, _hash(password));
  }

  @override
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_emailKey);
    final storedHash = prefs.getString(_passKey);
    if (storedEmail == null || storedHash == null) return false;
    return storedEmail == email.trim().toLowerCase() && storedHash == _hash(password);
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_passKey);
  }

  @override
  Future<String?> getAccountEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }
}
