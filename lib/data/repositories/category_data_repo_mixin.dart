import 'dart:async';

import 'package:my_resturant/core/constants/app_constants.dart';
import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:my_resturant/data/repositories/supabase_repo_base.dart';

mixin CategoryDataRepoMixin on SupabaseDataRepoBase {
  Future<List<Map<String, String>>> loadCategories() => safeCall(() async {
    final uid = userId;
    if (!isAuthed || uid == null) return [];
    final data = await client
        .from('categories')
        .select()
        .eq('restaurant_id', uid);
    return data.map(mapCategory).toList();
  });

  Future<void> addCategory(String key, String name, String icon) =>
      safeCall(() async {
        final uid = userId;
        if (!isAuthed || uid == null) return;
        if (key.isEmpty || key.length > 32) {
          throw Exception('Invalid category key');
        }
        final count = await client
            .from('categories')
            .select('key')
            .eq('restaurant_id', uid)
            .count();
        if (count.count >= AppConstants.maxCategoriesPerRestaurant) {
          throw Exception(
            'Maximum ${AppConstants.maxCategoriesPerRestaurant} categories reached',
          );
        }
        await client.from('categories').upsert({
          'key': key,
          'name': name,
          'icon': icon,
          'restaurant_id': uid,
        }, onConflict: 'key,restaurant_id');
      });

  Future<void> removeCategory(String key) => safeCall(() async {
    final uid = userId;
    if (!isAuthed || uid == null) return;
    await client
        .from('categories')
        .delete()
        .eq('key', key)
        .eq('restaurant_id', uid);
  });

  Stream<List<Map<String, String>>> watchCategories() {
    final uid = userId;
    if (!isAuthed || uid == null) return const Stream.empty();
    return client
        .from('categories')
        .stream(primaryKey: ['key', 'restaurant_id'])
        .eq('restaurant_id', uid)
        .map((data) => data.map(mapCategory).toList());
  }
}