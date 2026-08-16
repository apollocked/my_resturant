import 'package:flutter/foundation.dart';
import 'package:my_resturant/presentation/cubits/account_cubit_base.dart';
import 'package:my_resturant/presentation/cubits/account_state.dart';

mixin AccountManageMixin on AccountCubitBase {
  Future<void> claimPromoCode(String code) async {
    try {
      final ok = await repo.claimPromoCode(code);
      if (!isClosed) {
        emit(
          ok
              ? AccountState(
                  isLoggedIn: true,
                  isActivated: true,
                  email: state.email,
                )
              : AccountState(
                  isLoggedIn: true,
                  isActivated: false,
                  email: state.email,
                  errorMessage: 'err_invalid_promo',
                ),
        );
      }
    } catch (e, st) {
      debugPrint('AccountCubit.claimPromoCode error: $e\n$st');
      if (!isClosed) {
        emit(
          AccountState(
            isLoggedIn: true,
            isActivated: false,
            email: state.email,
            errorMessage: 'error_occurred',
          ),
        );
      }
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      await repo.updateEmail(newEmail);
      if (!isClosed) {
        emit(
          AccountState(
            isLoggedIn: true,
            isActivated: state.isActivated,
            email: newEmail.trim().toLowerCase(),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('AccountCubit.updateEmail error: $e\n$st');
      if (!isClosed) {
        emit(
          AccountState(
            isLoggedIn: true,
            isActivated: state.isActivated,
            email: state.email,
            errorMessage: '$e',
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await repo.updatePassword(currentPassword, newPassword);
    } catch (e, st) {
      debugPrint('AccountCubit.updatePassword error: $e\n$st');
      if (!isClosed) {
        emit(
          AccountState(
            isLoggedIn: true,
            isActivated: state.isActivated,
            email: state.email,
            errorMessage: '$e',
          ),
        );
      }
      rethrow;
    }
  }
}
