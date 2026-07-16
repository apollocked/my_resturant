import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
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
    await _client.from('profiles').update({column: _hash(newPin)}).eq('id', user.id);
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
}
