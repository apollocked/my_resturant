import 'package:my_resturant/domain/entities/role.dart';

abstract class AuthRepository {
  Future<bool> isAccountCreated();
  Future<void> createAccount(String email, String password);
  Future<bool> login(String email, String password);
  Future<void> logout();
  Future<String?> getAccountEmail();

  Future<bool> arePasscodesConfigured();
  Future<void> savePasscodes(String waiterPin, String kitchenPin, String adminPin);
  Future<bool> verifyPasscode(Role role, String pin);
  Future<void> changePasscode(Role role, String newPin);
}
