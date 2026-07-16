import 'package:my_resturant/domain/entities/role.dart';

abstract class AuthRepository {
  Future<bool> isAccountCreated();
  Future<void> createAccount(String email, String password);
  Future<bool> login(String email, String password);
  Future<void> logout();
  Future<String?> getAccountEmail();
  Future<void> updateEmail(String newEmail);
  Future<void> updatePassword(String currentPassword, String newPassword);

  Future<bool> arePasscodesConfigured();
  Future<void> savePasscodes(String waiterPin, String kitchenPin, String adminPin);
  Future<bool> verifyPasscode(Role role, String pin);
  Future<void> changePasscode(Role role, String newPin);
  Future<void> saveLoggedInRole(Role? role);
  Future<Role?> getLoggedInRole();
}
