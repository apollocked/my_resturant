import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

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
      return await _client.rpc('passcodes_configured') == true;
    } catch (e, st) {
      debugPrint('SupabaseAuthRepo.arePasscodesConfigured error: $e\n$st');
      return false;
    }
  }

  @override
  Future<void> savePasscodes(String waiterPin, String kitchenPin, String adminPin) async {
    await _client.rpc('save_passcodes', params: {
      'p_waiter': waiterPin,
      'p_kitchen': kitchenPin,
      'p_admin': adminPin,
    });
  }

  @override
  Future<bool> verifyPasscode(Role role, String pin) async {
    try {
      return await _client.rpc('verify_pin', params: {
        'p_role': role.name,
        'p_pin': pin,
      }) == true;
    } catch (e, st) {
      debugPrint('SupabaseAuthRepo.verifyPasscode error: $e\n$st');
      return false;
    }
  }

  @override
  Future<void> changePasscode(Role role, String newPin) async {
    await _client.rpc('change_passcode', params: {
      'p_role': role.name,
      'p_pin': newPin,
    });
  }

  @override
  Future<void> saveLoggedInRole(Role? role) async {
    await _client.rpc('set_role', params: {'p_role': role?.name});
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
