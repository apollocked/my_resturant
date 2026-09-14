import 'package:my_resturant/features/auth/domain/entities/role.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefRole = 'role_logged_in';
const _prefConfigured = 'passcodes_configured';
const _prefConfiguredAccounts = 'passcodes_configured_accounts';

/// Marks [email] as having role passcodes configured on this device.
///
/// Keeping the flag per account means a temporarily unreachable DB or a fresh
/// local store can never send an account that was already set up back to the
/// pin-setup page on later logins.
Future<void> markAccountConfigured(String? email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_prefConfigured, true);
  if (email == null || email.trim().isEmpty) return;
  final keys = prefs.getStringList(_prefConfiguredAccounts) ?? [];
  final normalized = email.trim().toLowerCase();
  if (!keys.contains(normalized)) {
    keys.add(normalized);
    await prefs.setStringList(_prefConfiguredAccounts, keys);
  }
}

/// True when [email] was previously seen fully configured on this device.
///
/// The legacy single flag still counts so installs that recorded it before the
/// per-account list was introduced keep working.
Future<bool> isAccountConfigured(String? email) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_prefConfigured) ?? false) return true;
  if (email == null || email.trim().isEmpty) return false;
  final keys = prefs.getStringList(_prefConfiguredAccounts) ?? [];
  return keys.contains(email.trim().toLowerCase());
}

Future<void> saveLocalRole(Role role) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_prefRole, role.name);
}

Future<Role?> loadLocalRole() async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString(_prefRole);
  if (name == null) return null;
  return RoleExtension.fromKey(name);
}

Future<void> clearLocalRole() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_prefRole);
}