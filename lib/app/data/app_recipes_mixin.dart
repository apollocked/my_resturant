import 'package:flutter/foundation.dart';
import 'package:my_resturant/features/menu/domain/entities/recipe.dart';
import 'package:my_resturant/app/data/app_repository.dart';
import 'package:my_resturant/app/data/datasources/local/app_database.dart';

mixin AppRecipesRepoMixin on AppRepositoryBase {
  Future<void> _emitRecipes() async {
    try {
      streams.recipes.add(await loadRecipes());
    } catch (e) {
      debugPrint('AppRepository._emitRecipes error: $e');
    }
  }

  Future<List<Recipe>> loadRecipes() => db.getAllRecipes();

  Future<void> addRecipe(Recipe r) async {
    await db.insertRecipe(r);
    _emitRecipes();
  }

  Future<void> editRecipe(
    String id, {
    String? name,
    double? price,
    String? category,
    String? description,
    String? imageUrl,
  }) async {
    await db.updateRecipeRecord(
      id,
      name: name,
      price: price,
      category: category,
      description: description,
      imageUrl: imageUrl,
    );
    _emitRecipes();
  }

  Future<void> removeRecipe(String id) async {
    await db.deleteRecipeRecord(id);
    _emitRecipes();
  }

  Future<void> toggleRecipe(String id) async {
    await db.toggleRecipeAvailability(id);
    _emitRecipes();
  }

  Stream<List<Recipe>> watchRecipes() => streams.recipes.stream;
}