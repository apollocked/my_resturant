import 'package:flutter/foundation.dart';
import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:my_resturant/features/auth/data/role_storage.dart';
import 'package:my_resturant/features/auth/domain/entities/role.dart';
import 'package:my_resturant/features/auth/presentation/cubits/role_cubit_base.dart';
import 'package:my_resturant/features/auth/presentation/cubits/role_state.dart';

/// Manages role-based sign-in on a shared account: setup passcodes, PIN login,
/// role switching and logout. The startup resolution lives in [RoleCubitBase].
class RoleCubit extends RoleCubitBase {
  RoleCubit({required super.repo});

  void clearError() => emit(RoleState(
        isConfigured: state.isConfigured,
        isLoggedIn: state.isLoggedIn,
        role: state.role,
      ));

  Future<void> configure(String w, String k, String a) async {
    try {
      await repo.savePasscodes(w, k, a);
      String? email;
      try {
        email = await repo.getAccountEmail();
      } catch (_) {}
      await markAccountConfigured(email);
      emit(const RoleState(isConfigured: true));
    } catch (e, st) {
      debugPrint('RoleCubit.configure error: $e\n$st');
      emit(RoleState(errorMessage: networkErrorKey(e)));
      rethrow;
    }
  }

  bool login(Role role, String pin) =>
      throw UnsupportedError('Use loginAsync instead');

  Future<bool> loginAsync(Role role, String pin) async {
    try {
      final ok = await repo.verifyPasscode(role, pin);
      if (ok) {
        await _activateRole(role, pin: pin);
      }
      return ok;
    } catch (e, st) {
      debugPrint('RoleCubit.loginAsync error: $e\n$st');
      _fail(networkErrorKey(e));
      return false;
    }
  }

  Future<bool> switchRole(Role role, {String? pin}) async {
    try {
      if (state.role == Role.admin) {
        await _activateRole(role);
        return true;
      }
      if (pin != null) {
        final ok = await repo.verifyPasscode(role, pin);
        if (ok) {
          await _activateRole(role, pin: pin);
          return true;
        }
        _fail('pin_invalid');
      }
      return false;
    } catch (e, st) {
      debugPrint('RoleCubit.switchRole error: $e\n$st');
      _fail(networkErrorKey(e));
      return false;
    }
  }

  /// Persists a role on the server + this device and marks the account
  /// configured, then emits the signed-in state.
  Future<void> _activateRole(Role role, {String? pin}) async {
    await repo.saveLoggedInRole(role, pin: pin);
    await saveLocalRole(role);
    String? email;
    try {
      email = await repo.getAccountEmail();
    } catch (_) {}
    await markAccountConfigured(email);
    emit(RoleState(isConfigured: true, isLoggedIn: true, role: role));
  }

  Future<void> logout() async {
    try {
      // Clear THIS device's server session first (set_role NULL). Must happen
      // while the token is still valid – account logout revokes it straight
      // after. On failure the local role is still cleared; the stale server
      // session is harmless because this device will re-login with a PIN.
      await repo.saveLoggedInRole(null);
    } catch (e, st) {
      debugPrint('RoleCubit.logout server clear failed: $e\n$st');
    }
    await clearLocalRole();
    emit(const RoleState(isConfigured: true));
  }

  Future<void> changePin(Role role, String newPin) async {
    try {
      await repo.changePasscode(role, newPin);
    } catch (e, st) {
      debugPrint('RoleCubit.changePin error: $e\n$st');
      _fail(networkErrorKey(e));
      rethrow;
    }
  }

  bool canSwitchFreely(Role target) => state.role == Role.admin;

  void _fail(String key) => emit(RoleState(
        isConfigured: state.isConfigured,
        isLoggedIn: state.isLoggedIn,
        role: state.role,
        errorMessage: key,
      ));
}