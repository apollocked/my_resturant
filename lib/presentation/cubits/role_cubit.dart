import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_resturant/domain/entities/role.dart';

class RoleState {
  final Role role;
  final bool isConfigured;
  final bool isLoggedIn;
  const RoleState({this.role = Role.admin, this.isConfigured = false, this.isLoggedIn = false});
}

class RoleCubit extends Cubit<RoleState> {
  static const _keyWaiter = 'pin_waiter';
  static const _keyKitchen = 'pin_kitchen';
  static const _keyAdmin = 'pin_admin';
  static const _keyLastRole = 'last_role';

  RoleCubit() : super(const RoleState());

  static String _pinKey(Role r) {
    switch (r) {
      case Role.waiter: return _keyWaiter;
      case Role.kitchen: return _keyKitchen;
      case Role.admin: return _keyAdmin;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final configured = prefs.containsKey(_keyWaiter) && prefs.containsKey(_keyKitchen) && prefs.containsKey(_keyAdmin);
    final lastRole = prefs.getString(_keyLastRole);
    final role = lastRole != null ? RoleExtension.fromKey(lastRole) : Role.admin;
    emit(RoleState(isConfigured: configured, role: role));
  }

  Future<void> configure(String waiterPin, String kitchenPin, String adminPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWaiter, waiterPin);
    await prefs.setString(_keyKitchen, kitchenPin);
    await prefs.setString(_keyAdmin, adminPin);
    emit(const RoleState(isConfigured: true));
  }

  bool login(Role role, String pin) {
    throw UnimplementedError('use loginAsync');
  }

  Future<bool> loginAsync(Role role, String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_pinKey(role));
    if (stored == null || stored != pin) return false;
    await prefs.setString(_keyLastRole, role.key);
    emit(RoleState(isConfigured: true, isLoggedIn: true, role: role));
    return true;
  }

  Future<void> switchRole(Role role, {String? pin}) async {
    if (state.role == Role.admin) {
      await _setRole(role);
      return;
    }
    final stored = (await SharedPreferences.getInstance()).getString(_pinKey(role));
    if (pin != null && stored == pin) {
      await _setRole(role);
    }
  }

  Future<void> _setRole(Role role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastRole, role.key);
    emit(RoleState(isConfigured: true, isLoggedIn: true, role: role));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final configured = prefs.containsKey(_keyWaiter);
    emit(RoleState(isConfigured: configured));
  }

  Future<void> changePin(Role role, String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey(role), newPin);
  }

  bool canSwitchFreely(Role target) => state.role == Role.admin;
}
