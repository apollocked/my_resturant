import 'package:flutter/foundation.dart';
import 'package:my_resturant/presentation/cubits/account_cubit_base.dart';
import 'package:my_resturant/presentation/cubits/account_state.dart';
import 'package:my_resturant/presentation/cubits/account_storage.dart';

mixin AccountSessionMixin on AccountCubitBase {
  Future<void> load() async {
    try {
      final savedEmail = await AccountStorage.readEmail();
      final savedLoggedIn = await AccountStorage.readLoggedIn();
      if (savedLoggedIn && savedEmail != null) {
        final activated = await repo.isActivated();
        emit(
          AccountState(
            isLoggedIn: true,
            isActivated: activated,
            email: savedEmail,
          ),
        );
        return;
      }
      final session = await repo.isAccountCreated();
      final email = await repo.getAccountEmail();
      if (session && email != null) {
        await AccountStorage.saveSession(email);
        final activated = await repo.isActivated();
        emit(
          AccountState(
            isLoggedIn: true,
            isActivated: activated,
            email: email,
          ),
        );
      }
    } catch (e, st) {
      debugPrint('AccountCubit.load error: $e\n$st');
    }
  }

  void clearError() => emit(
        AccountState(
          isLoggedIn: state.isLoggedIn,
          isActivated: state.isActivated,
          email: state.email,
        ),
      );

  Future<void> logout() async {
    try {
      await repo.logout();
    } catch (e, st) {
      debugPrint('AccountCubit.logout error: $e\n$st');
    }
    await AccountStorage.clearSession();
    if (!isClosed) emit(const AccountState());
  }
}
