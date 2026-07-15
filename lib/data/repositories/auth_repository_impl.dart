import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/domain/repositories/auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  static const _emailKey = 'account_email';
  static const _passKey = 'account_password_hash';
  static const _pinWaiter = 'pin_waiter';
  static const _pinKitchen = 'pin_kitchen';
  static const _pinAdmin = 'pin_admin';
  static const _loggedInRoleKey = 'logged_in_role';

  @override
  Future<bool> isAccountCreated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_emailKey) && prefs.containsKey(_passKey);
  }

  @override
  Future<void> createAccount(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email.trim().toLowerCase());
    await prefs.setString(_passKey, password);
  }

  @override
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_emailKey);
    final storedPass = prefs.getString(_passKey);
    if (storedEmail == null || storedPass == null) return false;
    return storedEmail == email.trim().toLowerCase() && storedPass == password;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<String?> getAccountEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  @override
  Future<bool> arePasscodesConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinWaiter) &&
        prefs.containsKey(_pinKitchen) &&
        prefs.containsKey(_pinAdmin);
  }

  @override
  Future<void> savePasscodes(String waiterPin, String kitchenPin, String adminPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinWaiter, waiterPin);
    await prefs.setString(_pinKitchen, kitchenPin);
    await prefs.setString(_pinAdmin, adminPin);
  }

  @override
  Future<bool> verifyPasscode(Role role, String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final key = switch (role) {
      Role.waiter => _pinWaiter,
      Role.kitchen => _pinKitchen,
      Role.admin => _pinAdmin,
    };
    final stored = prefs.getString(key);
    return stored != null && stored == pin;
  }

  @override
  Future<void> changePasscode(Role role, String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    final key = switch (role) {
      Role.waiter => _pinWaiter,
      Role.kitchen => _pinKitchen,
      Role.admin => _pinAdmin,
    };
    await prefs.setString(key, newPin);
  }

  @override
  Future<void> saveLoggedInRole(Role? role) async {
    final prefs = await SharedPreferences.getInstance();
    if (role != null) {
      await prefs.setString(_loggedInRoleKey, role.name);
    } else {
      await prefs.remove(_loggedInRoleKey);
    }
  }

  @override
  Future<Role?> getLoggedInRole() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_loggedInRoleKey);
    if (name == null) return null;
    return Role.values.firstWhere((r) => r.name == name);
  }
}
