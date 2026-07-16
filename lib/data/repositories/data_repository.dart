import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/repositories/data_repository.dart';
import 'package:my_resturant/data/datasources/local/app_database.dart';

final AppDatabase db = AppDatabase();

class AppRepository implements DataRepository {
  final _orderCtrl = StreamController<List<Order>>.broadcast();
  final _recipeCtrl = StreamController<List<Recipe>>.broadcast();
  final _settingCtrl = StreamController<Map<String, String>>.broadcast();

  void close() {
    _orderCtrl.close();
    _recipeCtrl.close();
    _settingCtrl.close();
  }

  Future<void> _emitOrders() async => _orderCtrl.add(await loadOrders());
  Future<void> _emitRecipes() async => _recipeCtrl.add(await loadRecipes());
  Future<void> _emitSettings() async => _settingCtrl.add(await loadSettings());

  // Recipes
  @override
  Future<List<Recipe>> loadRecipes() => db.getAllRecipes();

  @override
  Future<void> addRecipe(Recipe r) async {
    await db.insertRecipe(r);
    _emitRecipes();
  }

  @override
  Future<void> editRecipe(
    String id, {
    String? name,
    double? price,
    String? category,
    String? description,
  }) async {
    await db.updateRecipeRecord(
      id,
      name: name,
      price: price,
      category: category,
      description: description,
    );
    _emitRecipes();
  }

  @override
  Future<void> removeRecipe(String id) async {
    await db.deleteRecipeRecord(id);
    _emitRecipes();
  }

  @override
  Future<void> toggleRecipe(String id) async {
    await db.toggleRecipeAvailability(id);
    _emitRecipes();
  }

  @override
  Future<String> uploadImage(String recipeId, Uint8List bytes) async {
    final dir = Directory(
      'C:\\Users\\hamab\\Desktop\\Flutter_Projects\\my_resturant\\uploads\\recipes',
    );
    if (!await dir.exists()) await dir.create(recursive: true);
    final file = File('${dir.path}\\$recipeId.jpg');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  @override
  Stream<List<Recipe>> watchRecipes() => _recipeCtrl.stream;

  // Categories
  Future<List<Map<String, String>>> loadCategories() => db.getAllCategoryMaps();
  Future<void> addCategory(String key, String name, String icon) =>
      db.insertCategory(key, name, icon);

  // Orders
  @override
  Future<List<Order>> loadOrders() => db.getAllOrders();

  @override
  Future<void> saveOrder(Order order) async {
    await db.insertOrder(order);
    _emitOrders();
  }

  @override
  Future<void> changeOrderStatus(String id, OrderStatus status) async {
    await db.updateOrderStatusRecord(id, status);
    _emitOrders();
  }

  @override
  Future<void> deleteAllOrders() async {
    await db.deleteAllOrders();
    _emitOrders();
  }

  @override
  Stream<List<Order>> watchOrders() => _orderCtrl.stream;

  // Settings
  @override
  Future<Map<String, String>> loadSettings() => db.getSettings();

  @override
  Future<void> saveSetting(String key, String value) async {
    await db.setSetting(key, value);
    _emitSettings();
  }

  @override
  Stream<Map<String, String>> watchSettings() => _settingCtrl.stream;
}
