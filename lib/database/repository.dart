import 'package:my_resturant/database/database.dart';
import 'package:my_resturant/models/recipe.dart';
import 'package:my_resturant/models/order_model.dart';

final AppDatabase db = AppDatabase();

class AppRepository {
  // Recipes
  Future<List<Recipe>> loadRecipes() => db.getAllRecipes();

  Future<void> addRecipe(Recipe r) => db.insertRecipe(r);

  Future<void> editRecipe(String id, {String? name, double? price, String? category, String? description}) =>
      db.updateRecipeRecord(id, name: name, price: price, category: category, description: description);

  Future<void> removeRecipe(String id) => db.deleteRecipeRecord(id);

  Future<void> toggleRecipe(String id) => db.toggleRecipeAvailability(id);

  // Categories
  Future<List<Map<String, String>>> loadCategories() => db.getAllCategoryMaps();

  Future<void> addCategory(String key, String name, String icon) => db.insertCategory(key, name, icon);

  // Orders
  Future<List<Order>> loadOrders() => db.getAllOrders();

  Future<void> saveOrder(Order order) => db.insertOrder(order);

  Future<void> changeOrderStatus(String id, OrderStatus status) => db.updateOrderStatusRecord(id, status);

  // Settings
  Future<Map<String, String>> loadSettings() => db.getSettings();

  Future<void> saveSetting(String key, String value) => db.setSetting(key, value);
}
