import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/repositories/recipe_repository.dart';
import 'package:my_resturant/domain/repositories/order_repository.dart';
import 'package:my_resturant/domain/repositories/settings_repository.dart';
import 'package:my_resturant/data/datasources/local/app_database.dart';

final AppDatabase db = AppDatabase();

class AppRepository implements RecipeRepository, OrderRepository, SettingsRepository {
  // Recipes
  @override
  Future<List<Recipe>> loadRecipes() => db.getAllRecipes();

  @override
  Future<void> addRecipe(Recipe r) => db.insertRecipe(r);

  @override
  Future<void> editRecipe(String id, {String? name, double? price, String? category, String? description}) =>
      db.updateRecipeRecord(id, name: name, price: price, category: category, description: description);

  @override
  Future<void> removeRecipe(String id) => db.deleteRecipeRecord(id);

  @override
  Future<void> toggleRecipe(String id) => db.toggleRecipeAvailability(id);

  // Categories
  Future<List<Map<String, String>>> loadCategories() => db.getAllCategoryMaps();

  Future<void> addCategory(String key, String name, String icon) => db.insertCategory(key, name, icon);

  // Orders
  @override
  Future<List<Order>> loadOrders() => db.getAllOrders();

  @override
  Future<void> saveOrder(Order order) => db.insertOrder(order);

  @override
  Future<void> changeOrderStatus(String id, OrderStatus status) => db.updateOrderStatusRecord(id, status);

  // Settings
  @override
  Future<Map<String, String>> loadSettings() => db.getSettings();

  @override
  Future<void> saveSetting(String key, String value) => db.setSetting(key, value);
}
