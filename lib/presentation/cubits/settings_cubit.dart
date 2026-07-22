import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  final bool onboardingComplete;
  const SettingsState({this.themeMode = ThemeMode.light, this.locale = const Locale('ku'), this.onboardingComplete = false});

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale, bool? onboardingComplete}) =>
      SettingsState(themeMode: themeMode ?? this.themeMode, locale: locale ?? this.locale, onboardingComplete: onboardingComplete ?? this.onboardingComplete);
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString('themeMode');
    final localeStr = prefs.getString('locale');
    final onboarding = prefs.getBool('onboarding_complete') ?? false;
    emit(SettingsState(
      themeMode: switch (themeStr) { 'dark' => ThemeMode.dark, _ => ThemeMode.light },
      locale: Locale(localeStr ?? 'ku'),
      onboardingComplete: onboarding,
    ));
  }

  Future<void> completeOnboarding() async {
    emit(state.copyWith(onboardingComplete: true));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
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
