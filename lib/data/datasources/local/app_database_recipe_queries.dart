import 'package:drift/drift.dart';
import 'package:my_resturant/data/datasources/local/app_database.dart';
import 'package:my_resturant/domain/entities/recipe.dart';

extension AppDatabaseRecipeQueries on AppDatabase {
  Future<List<Recipe>> getAllRecipes() async {
    final rows = await select(recipes).get();
    return rows
        .map(
          (r) => Recipe(
            id: r.id,
            name: r.name,
            imageUrl: r.imageUrl,
            price: r.price,
            description: r.description,
            category: r.category,
            available: r.available,
          ),
        )
        .toList();
  }

  Future<Recipe?> getRecipeById(String id) async {
    final r = await (select(
      recipes,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (r == null) return null;
    return Recipe(
      id: r.id,
      name: r.name,
      imageUrl: r.imageUrl,
      price: r.price,
      description: r.description,
      category: r.category,
      available: r.available,
    );
  }

  Future<void> insertRecipe(Recipe recipe) async {
    await into(recipes).insert(
      RecipesCompanion.insert(
        id: recipe.id,
        name: recipe.name,
        imageUrl: recipe.imageUrl,
        price: recipe.price,
        description: recipe.description,
        category: recipe.category,
        available: Value(recipe.available),
      ),
    );
  }

  Future<void> updateRecipeRecord(
    String id, {
    String? name,
    double? price,
    String? category,
    String? description,
    String? imageUrl,
  }) async {
    await (update(recipes)..where((t) => t.id.equals(id))).write(
      RecipesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        price: price != null ? Value(price) : const Value.absent(),
        category: category != null ? Value(category) : const Value.absent(),
        description: description != null
            ? Value(description)
            : const Value.absent(),
        imageUrl: imageUrl != null ? Value(imageUrl) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteRecipeRecord(String id) async {
    await (delete(recipes)..where((t) => t.id.equals(id))).go();
  }

  Future<void> toggleRecipeAvailability(String id) async {
    final rows = await (select(recipes)..where((t) => t.id.equals(id))).get();
    if (rows.isEmpty) return;
    final r = rows.first;
    await (update(recipes)..where((t) => t.id.equals(id))).write(
      RecipesCompanion(available: Value(!r.available)),
    );
  }

  Future<List<Map<String, String>>> getAllCategoryMaps() async {
    final rows = await select(categories).get();
    return rows
        .map((c) => {'key': c.key, 'name': c.name, 'icon': c.icon})
        .toList();
  }

  Future<void> insertCategory(String key, String name, String icon) async {
    await into(
      categories,
    ).insert(CategoriesCompanion.insert(key: key, name: name, icon: icon));
  }

  Future<void> deleteCategoryByKey(String key) async {
    await (delete(categories)..where((t) => t.key.equals(key))).go();
  }
}
