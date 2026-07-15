import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_resturant/domain/entities/role.dart';

class RoleState {
  final Role role;
  const RoleState({this.role = Role.waiter});
}

class RoleCubit extends Cubit<RoleState> {
  static const _key = 'user_role';

  RoleCubit() : super(const RoleState());

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) emit(RoleState(role: RoleExtension.fromKey(saved)));
  }

  Future<void> setRole(Role role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, role.key);
    emit(RoleState(role: role));
  }
}
