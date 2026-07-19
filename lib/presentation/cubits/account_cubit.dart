import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_resturant/domain/repositories/auth_repository.dart';

String _errorKey(Object e) {
  if (e is AuthException) {
    return switch (e.code) {
      'invalid_credentials' => 'err_invalid_credentials',
      'email_not_confirmed' => 'err_email_not_confirmed',
      'user_already_exists' => 'err_email_exists',
      'over_email_send_rate_limit' || 'email_rate_limit' => 'err_rate_limit',
      'weak_password' => 'err_weak_password',
      _ => 'error_occurred',
    };
  }
  return 'error_occurred';
}

class AccountState {
  final bool isLoggedIn;
  final bool isActivated;
  final String? email;
  final String? errorMessage;
  const AccountState({
    this.isLoggedIn = false,
    this.isActivated = false,
    this.email,
    this.errorMessage,
  });
}

class AccountCubit extends Cubit<AccountState> {
  final AuthRepository _repo;

  AccountCubit({required this._repo}) : super(const AccountState());

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('account_email');
      final savedLoggedIn = prefs.getBool('account_logged_in') ?? false;
      if (savedLoggedIn && savedEmail != null) {
        final activated = await _repo.isActivated();
        emit(
          AccountState(
            isLoggedIn: true,
            isActivated: activated,
            email: savedEmail,
          ),
        );
        return;
      }
      final session = await _repo.isAccountCreated();
      final email = await _repo.getAccountEmail();
      if (session && email != null) {
        await prefs.setBool('account_logged_in', true);
        await prefs.setString('account_email', email);
        final activated = await _repo.isActivated();
        emit(
          AccountState(isLoggedIn: true, isActivated: activated, email: email),
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

  Future<void> createAccount(String email, String password) async {
    try {
      await _repo.createAccount(email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('account_logged_in', true);
      await prefs.setString('account_email', email.trim().toLowerCase());
      final activated = await _repo.isActivated();
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
      if (!isClosed) emit(AccountState(errorMessage: _errorKey(e)));
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final ok = await _repo.login(email, password);
      if (ok) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('account_logged_in', true);
        await prefs.setString('account_email', email.trim().toLowerCase());
        final activated = await _repo.isActivated();
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
      if (!isClosed) emit(AccountState(errorMessage: _errorKey(e)));
      return false;
    }
  }

  Future<void> claimPromoCode(String code) async {
    try {
      final ok = await _repo.claimPromoCode(code);
      if (ok) {
        if (!isClosed) {
          emit(
            AccountState(
              isLoggedIn: true,
              isActivated: true,
              email: state.email,
            ),
          );
        }
      } else {
        if (!isClosed) {
          emit(
            AccountState(
              isLoggedIn: true,
              isActivated: false,
              email: state.email,
              errorMessage: 'err_invalid_promo',
            ),
          );
        }
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

  Future<void> signInWithGoogle() async {
    try {
      await _repo.signInWithGoogle();
      final email = await _repo.getAccountEmail();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('account_logged_in', true);
      if (email != null) await prefs.setString('account_email', email);
      final activated = await _repo.isActivated();
      if (!isClosed) {
        emit(
          AccountState(isLoggedIn: true, isActivated: activated, email: email),
        );
      }
    } catch (e, st) {
      debugPrint('AccountCubit.signInWithGoogle error: $e\n$st');
      if (!isClosed) emit(const AccountState(errorMessage: 'error_occurred'));
    }
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (e, st) {
      debugPrint('AccountCubit.logout error: $e\n$st');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('account_logged_in');
    await prefs.remove('account_email');
    if (!isClosed) emit(const AccountState());
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      await _repo.updateEmail(newEmail);
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
      await _repo.updatePassword(currentPassword, newPassword);
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
