import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  const SettingsState({this.themeMode = ThemeMode.light, this.locale = const Locale('ku')});

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale}) =>
      SettingsState(themeMode: themeMode ?? this.themeMode, locale: locale ?? this.locale);
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void setThemeMode(ThemeMode mode) => emit(state.copyWith(themeMode: mode));
  void setLocale(Locale locale) => emit(state.copyWith(locale: locale));

  bool get isRtl => state.locale.languageCode != 'en';
}
