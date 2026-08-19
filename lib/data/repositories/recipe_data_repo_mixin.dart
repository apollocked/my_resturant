import 'dart:async';

import 'package:my_resturant/core/constants/app_constants.dart';
import 'package:my_resturant/core/helpers/network_helper.dart';
import 'package:my_resturant/data/repositories/supabase_repo_base.dart';
import 'package:my_resturant/domain/entities/recipe.dart';

mixin RecipeDataRepoMixin on SupabaseDataRepoBase {
  Future<List<Recipe>> loadRecipes() => safeCall(() async {
    if (!isAuthed) return [];
    final uid = userId;
    if (uid == null) return [];
    final data = await client.from('recipes').select().eq('restaurant_id', uid);
    return data.map(mapRecipe).toList();
  });

  Future<void> addRecipe(Recipe r) => safeCall(() async {
    final uid = userId;
    if (uid == null) return;
    final count = await client
        .from('recipes')
        .select('id')
        .eq('restaurant_id', uid)
        .count();
    if (count.count >= AppConstants.maxRecipesPerRestaurant) {
      throw Exception(
        'Maximum ${AppConstants.maxRecipesPerRestaurant} recipes reached',
      );
    }
    String imageUrl = r.imageUrl;
    if (!imageUrl.startsWith('http')) {
      imageUrl = await compressAndUpload(uid, r.id, imageUrl);
    }
    await client.from('recipes').insert({
      'id': r.id,
      'name': r.name,
      'image_url': imageUrl,
      'price': r.price,
      'description': r.description,
      'category': r.category,
      'available': r.available,
      'restaurant_id': uid,
    });
  });

  Future<void> editRecipe(
    String id, {
    String? name,
    double? price,
    String? category,
    String? description,
    String? imageUrl,
  }) => safeCall(() async {
    final uid = userId;
    if (!isAuthed || uid == null) return;
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (price != null) updates['price'] = price;
    if (category != null) updates['category'] = category;
    if (description != null) updates['description'] = description;
    if (imageUrl != null) updates['image_url'] = imageUrl;
    if (updates.isNotEmpty) {
      await client
          .from('recipes')
          .update(updates)
          .eq('id', id)
          .eq('restaurant_id', uid);
    }
  });

  Future<void> removeRecipe(String id) => safeCall(() async {
    final uid = userId;
    if (!isAuthed || uid == null) return;
    await client.from('recipes').delete().eq('id', id).eq('restaurant_id', uid);
  });

  Future<void> toggleRecipe(String id) => safeCall(() async {
    final uid = userId;
    if (!isAuthed || uid == null) return;
    final data = await client
        .from('recipes')
        .select('available')
        .eq('id', id)
        .eq('restaurant_id', uid)
        .maybeSingle();
    if (data == null) return;
    await client
        .from('recipes')
        .update({'available': !(data['available'] as bool? ?? false)})
        .eq('id', id)
        .eq('restaurant_id', uid);
  });

  Stream<List<Recipe>> watchRecipes() {
    if (!isAuthed) return const Stream.empty();
    final uid = userId;
    if (uid == null) return const Stream.empty();
    return client
        .from('recipes')
        .stream(primaryKey: ['id'])
        .eq('restaurant_id', uid)
        .map((data) => data.map(mapRecipe).toList());
  }
}
