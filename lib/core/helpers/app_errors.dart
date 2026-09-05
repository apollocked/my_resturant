import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps an arbitrary exception to a localization key so that raw (often
/// English) error text never leaks to the user. The returned key is meant to
/// be passed to the app's `t(...)` / `Tr.get(...)` lookup.
String localizedErrorKey(Object e) {
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
  if (e is TimeoutException) return 'err_network';
  if (e is SocketException) return 'err_network';
  if (e is Exception && e.toString().contains('SocketException')) {
    return 'err_network';
  }
  return 'error_occurred';
}