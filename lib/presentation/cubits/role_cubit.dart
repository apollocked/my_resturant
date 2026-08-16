import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleState {
  final Role role;
  final bool isConfigured;
  final bool isLoggedIn;
  final String? errorMessage;
  const RoleState({
    this.role = Role.admin,
    this.isConfigured = false,
    this.isLoggedIn = false,
    this.errorMessage,
  });
}

class RoleCubit extends Cubit<RoleState> {
  final AuthRepository _repo;
  static const _prefRole = 'role_logged_in';

  RoleCubit({required this._repo}) : super(const RoleState());

  // The role session is restored from the server (profiles.role), never from
  // local prefs, so a tampered local cache cannot grant a role. Returning to
  // the last-used role on cold start needs no PIN; PINs still gate switching
  // into admin from a non-admin role.
  Future<void> load() async {
    try {
      final configured = await _repo.arePasscodesConfigured();
      if (!configured) {
        emit(const RoleState());
        return;
      }
      var role = await _repo.getLoggedInRole();
      if (role == null) {
        role = await _localRole();
      } else {
        await _saveLocal(role);
      }
      emit(
        RoleState(
          isConfigured: true,
          isLoggedIn: role != null,
          role: role ?? Role.admin,
        ),
      );
    } catch (e, st) {
      debugPrint('RoleCubit.load error: $e\n$st');
      emit(const RoleState());
    }
  }

  void clearError() => emit(
    RoleState(
      isConfigured: state.isConfigured,
      isLoggedIn: state.isLoggedIn,
      role: state.role,
    ),
  );

  Future<void> configure(
    String waiterPin,
    String kitchenPin,
    String adminPin,
  ) async {
    try {
      await _repo.savePasscodes(waiterPin, kitchenPin, adminPin);
      emit(const RoleState(isConfigured: true));
    } catch (e, st) {
      debugPrint('RoleCubit.configure error: $e\n$st');
      emit(RoleState(errorMessage: '$e'));
      rethrow;
    }
  }

  bool login(Role role, String pin) {
    throw UnsupportedError('Use loginAsync instead');
  }

  Future<bool> loginAsync(Role role, String pin) async {
    try {
      final ok = await _repo.verifyPasscode(role, pin);
      if (ok) {
        await _repo.saveLoggedInRole(role, pin: pin);
        await _saveLocal(role);
        emit(RoleState(isConfigured: true, isLoggedIn: true, role: role));
      }
      return ok;
    } catch (e, st) {
      debugPrint('RoleCubit.loginAsync error: $e\n$st');
      emit(RoleState(errorMessage: '$e'));
      return false;
    }
  }

  Future<bool> switchRole(Role role, {String? pin}) async {
    if (state.role == Role.admin) {
      await _setRole(role);
      return true;
    }
    if (pin != null) {
      final ok = await _repo.verifyPasscode(role, pin);
      if (ok) {
        await _setRole(role, pin: pin);
        return true;
      }
      emit(
        RoleState(
          isConfigured: state.isConfigured,
          isLoggedIn: state.isLoggedIn,
          role: state.role,
          errorMessage: 'pin_invalid',
        ),
      );
    }
    return false;
  }

  Future<void> _setRole(Role role, {String? pin}) async {
    await _repo.saveLoggedInRole(role, pin: pin);
    await _saveLocal(role);
    emit(RoleState(isConfigured: true, isLoggedIn: true, role: role));
  }

  Future<void> logout() async {
    try {
      await _repo.saveLoggedInRole(null);
    } catch (e, st) {
      debugPrint('RoleCubit.logout error (best-effort): $e\n$st');
    }
    await _clearLocal();
    emit(const RoleState(isConfigured: true));
  }

  Future<void> changePin(Role role, String newPin) async {
    await _repo.changePasscode(role, newPin);
  }

  bool canSwitchFreely(Role target) => state.role == Role.admin;

  Future<void> _saveLocal(Role role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefRole, role.name);
  }

  Future<Role?> _localRole() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_prefRole);
    if (name == null) return null;
    return RoleExtension.fromKey(name);
  }

  Future<void> _clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefRole);
  }
}
