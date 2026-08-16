import 'package:my_resturant/data/repositories/auth_repo_base.dart';
import 'package:my_resturant/data/repositories/auth_repo_rpc_mixin.dart';
import 'package:my_resturant/data/repositories/auth_repo_session_mixin.dart';

class SupabaseAuthRepository extends SupabaseAuthRepositoryBase
    with AuthSessionMixin, AuthRpcMixin {
  SupabaseAuthRepository();
}
