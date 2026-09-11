import 'package:my_resturant/domain/entities/role.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefRole = 'role_logged_in';
const _prefConfigured = 'passcodes_configured';

Future<void> savePasscodesConfigured(bool configured) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_prefConfigured, configured);
}

Future<bool> loadPasscodesConfigured() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_prefConfigured) ?? false;
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
