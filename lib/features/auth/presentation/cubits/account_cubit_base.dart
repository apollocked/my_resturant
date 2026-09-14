import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/features/auth/domain/repositories/auth_repository.dart';
import 'package:my_resturant/features/auth/presentation/cubits/account_state.dart';

class AccountCubitBase extends Cubit<AccountState> {
  AccountCubitBase({required this.repo}) : super(const AccountState());

  final AuthRepository repo;
}
