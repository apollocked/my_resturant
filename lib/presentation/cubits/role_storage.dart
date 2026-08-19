import 'package:my_resturant/domain/entities/role.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefRole = 'role_logged_in';

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
