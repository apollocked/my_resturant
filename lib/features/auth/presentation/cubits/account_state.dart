import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

String accountErrorKey(Object e) {
  if (e is AuthException) {
    final mapped = switch (e.code) {
      'invalid_credentials' => 'err_invalid_credentials',
      'email_not_confirmed' => 'err_email_not_confirmed',
      'user_already_exists' => 'err_email_exists',
      'over_email_send_rate_limit' || 'email_rate_limit' => 'err_rate_limit',
      'weak_password' => 'err_weak_password',
      _ => null,
    };
    if (mapped != null) return mapped;
  }
  return networkErrorKey(e);
}
