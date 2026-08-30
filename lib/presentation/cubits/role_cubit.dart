import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/domain/repositories/auth_repository.dart';
import 'package:my_resturant/presentation/cubits/role_storage.dart';

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

  RoleCubit({required this._repo}) : super(const RoleState());

  Future<void> load() async {
    try {
      bool configured = false;
      try {
        configured = await _repo.arePasscodesConfigured();
      } catch (_) {
        final local = await loadLocalRole();
        if (local != null) {
          emit(RoleState(isConfigured: true, isLoggedIn: true, role: local));
          return;
        }
        return;
      }
      if (!configured) {
        emit(const RoleState());
        return;
      }
      Role? role;
      try {
        role = await _repo.getLoggedInRole();
      } catch (_) {}
      if (role == null) {
        role = await loadLocalRole();
      } else {
        await saveLocalRole(role);
      }
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

  Future<void> configure(String w, String k, String a) async {
    try {
      await _repo.savePasscodes(w, k, a);
      emit(const RoleState(isConfigured: true));
    } catch (e, st) {
      debugPrint('RoleCubit.configure error: $e\n$st');
      emit(RoleState(errorMessage: '$e'));
      rethrow;
    }
  }

  bool login(Role role, String pin) =>
      throw UnsupportedError('Use loginAsync instead');

  Future<bool> loginAsync(Role role, String pin) async {
    try {
      final ok = await _repo.verifyPasscode(role, pin);
      if (ok) {
        await _repo.saveLoggedInRole(role, pin: pin);
        await saveLocalRole(role);
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
    try {
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
        emit(RoleState(
          isConfigured: state.isConfigured,
          isLoggedIn: state.isLoggedIn,
          role: state.role,
          errorMessage: 'pin_invalid',
        ));
      }
      return false;
    } catch (e, st) {
      debugPrint('RoleCubit.switchRole error: $e\n$st');
      emit(RoleState(
        isConfigured: state.isConfigured,
        isLoggedIn: state.isLoggedIn,
        role: state.role,
        errorMessage: 'error_occurred',
      ));
      return false;
    }
  }

  Future<void> _setRole(Role role, {String? pin}) async {
    await _repo.saveLoggedInRole(role, pin: pin);
    await saveLocalRole(role);
    emit(RoleState(isConfigured: true, isLoggedIn: true, role: role));
  }

  Future<void> logout() async {
    await clearLocalRole();
    emit(const RoleState(isConfigured: true));
  }

  Future<void> changePin(Role role, String newPin) async {
    try {
      await _repo.changePasscode(role, newPin);
    } catch (e, st) {
      debugPrint('RoleCubit.changePin error: $e\n$st');
      emit(RoleState(
        isConfigured: state.isConfigured,
        isLoggedIn: state.isLoggedIn,
        role: state.role,
        errorMessage: 'error_occurred',
      ));
      rethrow;
    }
  }

  bool canSwitchFreely(Role target) => state.role == Role.admin;
}
