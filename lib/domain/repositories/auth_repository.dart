abstract class AuthRepository {
  Future<bool> isAccountCreated();
  Future<void> createAccount(String email, String password);
  Future<bool> login(String email, String password);
  Future<void> logout();
  Future<String?> getAccountEmail();
}
