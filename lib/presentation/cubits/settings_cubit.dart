import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  const SettingsState({this.themeMode = ThemeMode.light, this.locale = const Locale('ku')});

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale}) =>
      SettingsState(themeMode: themeMode ?? this.themeMode, locale: locale ?? this.locale);
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString('themeMode');
    final localeStr = prefs.getString('locale');
    emit(SettingsState(
      themeMode: switch (themeStr) { 'dark' => ThemeMode.dark, _ => ThemeMode.light },
      locale: Locale(localeStr ?? 'ku'),
    ));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> setLocale(Locale locale) async {
    emit(state.copyWith(locale: locale));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  bool get isRtl => state.locale.languageCode != 'en';
}
