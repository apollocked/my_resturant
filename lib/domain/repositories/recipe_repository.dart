import 'dart:async';
import 'dart:typed_data';
import 'package:my_resturant/domain/entities/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> loadRecipes();
  Future<void> addRecipe(Recipe recipe);
  Future<void> editRecipe(String id, {String? name, double? price, String? category, String? description});
  Future<void> removeRecipe(String id);
  Future<void> toggleRecipe(String id);
  Future<String> uploadImage(String recipeId, Uint8List bytes);
  Stream<List<Recipe>> watchRecipes();
}
