import 'dart:async';

abstract class SettingsRepository {
  Future<Map<String, String>> loadSettings();
  Future<void> saveSetting(String key, String value);
  Stream<Map<String, String>> watchSettings();
}
