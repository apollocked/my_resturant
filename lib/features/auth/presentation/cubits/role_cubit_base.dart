import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/features/auth/data/role_storage.dart';
import 'package:my_resturant/features/auth/domain/entities/role.dart';
import 'package:my_resturant/features/auth/domain/repositories/auth_repository.dart';
import 'package:my_resturant/features/auth/presentation/cubits/role_state.dart';

/// Base role cubit: holds the repository and resolves the account's stored
/// configuration on startup ([load]) with local-device fallbacks when the
/// database is unreachable.
class RoleCubitBase extends Cubit<RoleState> {
  final AuthRepository repo;

  RoleCubitBase({required this.repo}) : super(const RoleState());

  Future<void> load() async {
    try {
      String? email;
      try {
        email = await repo.getAccountEmail();
      } catch (_) {
        email = null;
      }
      bool configured = false;
      try {
        configured = await repo.arePasscodesConfigured();
      } catch (_) {
        // DB unreachable/failing: fall back to what this device already knows
        // so an already-configured account goes to role-login, not setup.
        final local = await loadLocalRole();
        if (local != null) {
          emit(RoleState(isConfigured: true, isLoggedIn: true, role: local));
          return;
        }
        if (await isAccountConfigured(email)) {
          emit(const RoleState(isConfigured: true));
          return;
        }
        return;
      }
      if (!configured) {
        // DB says this account has no pins, but it was set up on this device
        // before – never ask an existing account for passcodes again.
        if (await isAccountConfigured(email)) {
          emit(const RoleState(isConfigured: true));
          return;
        }
        emit(const RoleState());
        return;
      }
      await markAccountConfigured(email);
      Role? role;
      var serverOk = true;
      try {
        role = await repo.getLoggedInRole();
      } catch (e, st) {
        serverOk = false;
        debugPrint('RoleCubit.load getLoggedInRole error: $e\n$st');
      }
      if (!serverOk) {
        role = await loadLocalRole();
      } else if (role == null) {
        // Reachable server, but THIS device has no role yet → force role-login
        // (a fresh install / logged-out device on a shared account).
        await clearLocalRole();
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
}