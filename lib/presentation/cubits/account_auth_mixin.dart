import 'package:flutter/foundation.dart';
import 'package:my_resturant/presentation/cubits/account_cubit_base.dart';
import 'package:my_resturant/presentation/cubits/account_state.dart';
import 'package:my_resturant/presentation/cubits/account_storage.dart';

mixin AccountAuthMixin on AccountCubitBase {
  Future<void> createAccount(String email, String password) async {
    try {
      await repo.createAccount(email, password);
      await AccountStorage.saveSession(email.trim().toLowerCase());
      final activated = await repo.isActivated();
      if (!isClosed) {
        emit(
          AccountState(
            isLoggedIn: true,
            isActivated: activated,
            email: email.trim().toLowerCase(),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('AccountCubit.createAccount error: $e\n$st');
      if (!isClosed) emit(AccountState(errorMessage: accountErrorKey(e)));
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final ok = await repo.login(email, password);
      if (ok) {
        await AccountStorage.saveSession(email.trim().toLowerCase());
        final activated = await repo.isActivated();
        if (!isClosed) {
          emit(
            AccountState(
              isLoggedIn: true,
              isActivated: activated,
              email: email.trim().toLowerCase(),
            ),
          );
        }
      }
      return ok;
    } catch (e, st) {
      debugPrint('AccountCubit.login error: $e\n$st');
      if (!isClosed) emit(AccountState(errorMessage: accountErrorKey(e)));
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await repo.signInWithGoogle();
      final email = await repo.getAccountEmail();
      await AccountStorage.markLoggedIn(email: email);
      final activated = await repo.isActivated();
      if (!isClosed) {
        emit(
          AccountState(
            isLoggedIn: true,
            isActivated: activated,
            email: email,
          ),
        );
      }
    } catch (e, st) {
      debugPrint('AccountCubit.signInWithGoogle error: $e\n$st');
      if (!isClosed) emit(const AccountState(errorMessage: 'error_occurred'));
    }
  }
}
