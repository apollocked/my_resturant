import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/domain/repositories/auth_repository.dart';
import 'package:my_resturant/presentation/cubits/account_state.dart';

class AccountCubitBase extends Cubit<AccountState> {
  AccountCubitBase({required this.repo}) : super(const AccountState());

  final AuthRepository repo;
}
