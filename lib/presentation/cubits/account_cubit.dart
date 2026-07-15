import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/domain/repositories/auth_repository.dart';

class AccountState {
  final bool isLoggedIn;
  final String? email;
  const AccountState({this.isLoggedIn = false, this.email});
}

class AccountCubit extends Cubit<AccountState> {
  final AuthRepository _repo;

  AccountCubit({required this._repo}) : super(const AccountState());

  Future<void> load() async {
    final session = await _repo.isAccountCreated();
    final email = await _repo.getAccountEmail();
    if (session && email != null) {
      emit(AccountState(isLoggedIn: true, email: email));
    }
  }

  Future<void> createAccount(String email, String password) async {
    await _repo.createAccount(email, password);
    emit(AccountState(
      isLoggedIn: true,
      email: email.trim().toLowerCase(),
    ));
  }

  Future<bool> login(String email, String password) async {
    final ok = await _repo.login(email, password);
    if (ok) {
      emit(AccountState(
        isLoggedIn: true,
        email: email.trim().toLowerCase(),
      ));
    }
    return ok;
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(const AccountState());
  }
}
