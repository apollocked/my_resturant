import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  String _hash(String input) => sha256.convert(utf8.encode(input)).toString();

  @override
  Future<bool> isAccountCreated() async {
    return _client.auth.currentSession != null;
  }

  @override
  Future<void> createAccount(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
    );
    if (response.user == null) {
      throw Exception('Failed to create account');
    }
    if (response.session == null) {
      final login = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      if (login.user == null) {
        throw const AuthException('Email confirmation required. Check your inbox.', code: 'email_not_confirmed');
      }
    }
  }

  @override
  Future<bool> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    return response.user != null;
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    await _client.auth.updateUser(UserAttributes(email: newEmail.trim().toLowerCase()));
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    final email = user.email;
    if (email == null) throw Exception('No email on account');
    final login = await _client.auth.signInWithPassword(
      email: email,
      password: currentPassword,
    );
    if (login.session == null) {
      throw Exception('Current password is incorrect');
    }
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<String?> getAccountEmail() async {
    return _client.auth.currentUser?.email;
  }

  @override
  Future<bool> arePasscodesConfigured() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      final data = await _client
          .from('profiles')
          .select('pin_waiter, pin_kitchen, pin_admin')
          .eq('id', user.id)
          .single();
      return (data['pin_waiter']?.isNotEmpty == true &&
          data['pin_kitchen']?.isNotEmpty == true &&
          data['pin_admin']?.isNotEmpty == true);
    } catch (e, st) {
      debugPrint('SupabaseAuthRepo.arePasscodesConfigured error: $e\n$st');
      return false;
    }
  }

  @override
  Future<void> savePasscodes(String waiterPin, String kitchenPin, String adminPin) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    await _client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'pin_waiter': _hash(waiterPin),
      'pin_kitchen': _hash(kitchenPin),
      'pin_admin': _hash(adminPin),
    });
  }

  @override
  Future<bool> verifyPasscode(Role role, String pin) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      final column = switch (role) {
        Role.waiter => 'pin_waiter',
        Role.kitchen => 'pin_kitchen',
        Role.admin => 'pin_admin',
      };
      final data = await _client
          .from('profiles')
          .select(column)
          .eq('id', user.id)
          .single();
      return data[column] == _hash(pin);
    } catch (e, st) {
      debugPrint('SupabaseAuthRepo.verifyPasscode error: $e\n$st');
      return false;
    }
  }

  @override
  Future<void> changePasscode(Role role, String newPin) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    final column = switch (role) {
      Role.waiter => 'pin_waiter',
      Role.kitchen => 'pin_kitchen',
      Role.admin => 'pin_admin',
    };
    final existing = await _client.from('profiles').select('pin_waiter, pin_kitchen, pin_admin').eq('id', user.id).maybeSingle();
    await _client.from('profiles').upsert({
      'id': user.id,
      'pin_waiter': existing?['pin_waiter'] ?? '',
      'pin_kitchen': existing?['pin_kitchen'] ?? '',
      'pin_admin': existing?['pin_admin'] ?? '',
      column: _hash(newPin),
    });
  }

  @override
  Future<void> saveLoggedInRole(Role? role) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('profiles').upsert({
      'id': user.id,
      'role': role?.name,
    });
  }

  @override
  Future<Role?> getLoggedInRole() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final data = await _client.from('profiles').select('role').eq('id', user.id).single();
    final name = data['role'] as String?;
    if (name == null) return null;
    return Role.values.firstWhere((r) => r.name == name);
  }

  @override
  Future<bool> isActivated() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      final data = await _client.from('profiles').select('activated').eq('id', user.id).single();
      return data['activated'] == true;
    } catch (e, st) {
      debugPrint('SupabaseAuthRepo.isActivated error: $e\n$st');
      return false;
    }
  }

  @override
  Future<bool> claimPromoCode(String code) async {
    try {
      final result = await _client.rpc('claim_promo_code', params: {'promo_code': code.trim().toUpperCase()});
      return result == true;
    } catch (e, st) {
      debugPrint('SupabaseAuthRepo.claimPromoCode error: $e\n$st');
      return false;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    final webClientId = dotenv.env['WEB_CLIENT_ID'] ?? '';

    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(serverClientId: webClientId.isNotEmpty ? webClientId : null);

    final googleUser = await googleSignIn.authenticate();

    final authorization = await googleUser.authorizationClient.authorizationForScopes(['email', 'profile'])
        ?? await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);

    final idToken = googleUser.authentication.idToken;
    if (idToken == null) throw const AuthException('No ID token from Google');

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization.accessToken,
    );
  }
}
