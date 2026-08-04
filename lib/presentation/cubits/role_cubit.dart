import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/domain/repositories/auth_repository.dart';

class RoleState {
  final Role role;
  final bool isConfigured;
  final bool isLoggedIn;
  final String? errorMessage;
  const RoleState({this.role = Role.admin, this.isConfigured = false, this.isLoggedIn = false, this.errorMessage});
}

class RoleCubit extends Cubit<RoleState> {
  final AuthRepository _repo;

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
      final role = await _repo.getLoggedInRole();
      emit(RoleState(
        isConfigured: true,
        isLoggedIn: role != null,
        role: role ?? Role.admin,
      ));
    } catch (e, st) {
      debugPrint('RoleCubit.load error: $e\n$st');
      emit(const RoleState());
    }
  }

  void clearError() => emit(RoleState(
    isConfigured: state.isConfigured,
    isLoggedIn: state.isLoggedIn,
    role: state.role,
  ));

  Future<void> configure(String waiterPin, String kitchenPin, String adminPin) async {
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
        await _repo.saveLoggedInRole(role);
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
        await _setRole(role);
        return true;
      }
      emit(RoleState(isConfigured: state.isConfigured, isLoggedIn: state.isLoggedIn, role: state.role, errorMessage: 'pin_invalid'));
    }
    return false;
  }

  Future<void> _setRole(Role role) async {
    await _repo.saveLoggedInRole(role);
    emit(RoleState(isConfigured: true, isLoggedIn: true, role: role));
  }

  Future<void> logout() async {
    await _repo.saveLoggedInRole(null);
    emit(const RoleState(isConfigured: true));
  }

  Future<void> changePin(Role role, String newPin) async {
    await _repo.changePasscode(role, newPin);
  }

  bool canSwitchFreely(Role target) => state.role == Role.admin;
}
