import 'package:flutter/foundation.dart';
import 'package:my_resturant/app/data/app_repository.dart';
import 'package:my_resturant/app/data/datasources/local/app_database.dart';

mixin AppSettingsRepoMixin on AppRepositoryBase {
  Future<void> _emitSettings() async {
    try {
      streams.settings.add(await loadSettings());
    } catch (e) {
      debugPrint('AppRepository._emitSettings error: $e');
    }
  }

  Future<Map<String, String>> loadSettings() => db.getSettings();

  Future<void> saveSetting(String key, String value) async {
    await db.setSetting(key, value);
    _emitSettings();
  }

  Stream<Map<String, String>> watchSettings() => streams.settings.stream;
}