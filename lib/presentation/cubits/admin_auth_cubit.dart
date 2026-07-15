import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthState {
  final bool authenticated;
  final String pin;
  const AdminAuthState({this.authenticated = false, this.pin = '1234'});
}

class AdminAuthCubit extends Cubit<AdminAuthState> {
  static const _pinKey = 'admin_pin';
  AdminAuthCubit() : super(const AdminAuthState());

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString(_pinKey) ?? '1234';
    emit(AdminAuthState(pin: pin));
  }

  bool authenticate(String pin) {
    if (pin == state.pin) { emit(AdminAuthState(authenticated: true, pin: state.pin)); return true; }
    return false;
  }

  Future<void> changePin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, newPin);
    emit(AdminAuthState(authenticated: state.authenticated, pin: newPin));
  }

  void logout() => emit(AdminAuthState(authenticated: false, pin: state.pin));
}
