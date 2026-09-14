import 'package:my_resturant/features/auth/presentation/cubits/account_auth_mixin.dart';
import 'package:my_resturant/features/auth/presentation/cubits/account_cubit_base.dart';
import 'package:my_resturant/features/auth/presentation/cubits/account_manage_mixin.dart';
import 'package:my_resturant/features/auth/presentation/cubits/account_session_mixin.dart';

class AccountCubit extends AccountCubitBase
    with AccountSessionMixin, AccountAuthMixin, AccountManageMixin {
  AccountCubit({required super.repo});
}
