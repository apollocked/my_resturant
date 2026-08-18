import 'dart:async';

import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:my_resturant/data/repositories/supabase_repo_base.dart';

mixin SettingDataRepoMixin on SupabaseDataRepoBase {
  Future<Map<String, String>> loadSettings() => safeCall(() async {
    if (!isAuthed) return {};
    final uid = userId;
    if (uid == null) return {};
    final data = await client
        .from('app_settings')
        .select()
        .eq('restaurant_id', uid);
    return {
      for (final row in data)
        (row['key'] as String? ?? ''): (row['value'] as String? ?? ''),
    };
  });

  Future<void> saveSetting(String key, String value) => safeCall(() async {
    final uid = userId;
    if (uid == null) return;
    await client.from('app_settings').upsert({
      'key': key,
      'value': value,
      'restaurant_id': uid,
    }, onConflict: 'key, restaurant_id');
  });

  Stream<Map<String, String>> watchSettings() {
    if (!isAuthed) return const Stream.empty();
    final uid = userId;
    if (uid == null) return const Stream.empty();
    return client
        .from('app_settings')
        .stream(primaryKey: ['key', 'restaurant_id'])
        .eq('restaurant_id', uid)
        .map(
          (data) => {
            for (final row in data)
              (row['key'] as String? ?? ''): (row['value'] as String? ?? ''),
          },
        );
  }
}
