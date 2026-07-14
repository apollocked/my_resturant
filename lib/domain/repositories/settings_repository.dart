abstract class SettingsRepository {
  Future<Map<String, String>> loadSettings();
  Future<void> saveSetting(String key, String value);
}
