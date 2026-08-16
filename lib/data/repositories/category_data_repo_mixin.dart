import 'dart:async';

import 'package:my_resturant/core/constants/app_constants.dart';
import 'package:my_resturant/data/repositories/supabase_repo_base.dart';

mixin CategoryDataRepoMixin on SupabaseDataRepoBase {
  Future<List<Map<String, String>>> loadCategories() async {
    if (!isAuthed) return [];
    final data = await client.from('categories').select();
    return data.map(mapCategory).toList();
  }

  Future<void> addCategory(String key, String name, String icon) async {
    if (key.isEmpty || key.length > 32) {
      throw Exception('Invalid category key');
    }
    final count = await client.from('categories').select('key').count();
    if (count.count >= AppConstants.maxCategoriesPerRestaurant) {
      throw Exception(
        'Maximum ${AppConstants.maxCategoriesPerRestaurant} categories reached',
      );
    }
    await client.from('categories').upsert({
      'key': key,
      'name': name,
      'icon': icon,
    }, onConflict: 'key');
  }

  Future<void> removeCategory(String key) async {
    await client.from('categories').delete().eq('key', key);
  }

  Stream<List<Map<String, String>>> watchCategories() {
    if (!isAuthed) return const Stream.empty();
    return client
        .from('categories')
        .stream(primaryKey: ['key'])
        .map((data) => data.map(mapCategory).toList());
  }
}
