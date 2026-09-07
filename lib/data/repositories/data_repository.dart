import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/repositories/data_repository.dart';
import 'package:my_resturant/data/datasources/local/app_database.dart';

final AppDatabase db = AppDatabase();

class AppRepository implements DataRepository {
  final _orderCtrl = StreamController<List<Order>>.broadcast();
  final _recipeCtrl = StreamController<List<Recipe>>.broadcast();
  final _settingCtrl = StreamController<Map<String, String>>.broadcast();
  final _categoryCtrl = StreamController<List<Map<String, String>>>.broadcast();

  void close() {
    _orderCtrl.close();
    _recipeCtrl.close();
    _settingCtrl.close();
    _categoryCtrl.close();
  }

  Future<void> _emitOrders() async {
    try {
      _orderCtrl.add(await loadOrders());
    } catch (e) {
      debugPrint('AppRepository._emitOrders error: $e');
    }
  }

  Future<void> _emitRecipes() async {
    try {
      _recipeCtrl.add(await loadRecipes());
    } catch (e) {
      debugPrint('AppRepository._emitRecipes error: $e');
    }
  }

  Future<void> _emitSettings() async {
    try {
      _settingCtrl.add(await loadSettings());
    } catch (e) {
      debugPrint('AppRepository._emitSettings error: $e');
    }
  }

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
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'uploads', 'recipes'));
    if (!await dir.exists()) await dir.create(recursive: true);
    final file = File(p.join(dir.path, '$recipeId.jpg'));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  @override
  Stream<List<Recipe>> watchRecipes() => _recipeCtrl.stream;

  // Categories
  @override
  Future<List<Map<String, String>>> loadCategories() => db.getAllCategoryMaps();
  @override
  Future<void> addCategory(String key, String name, String icon) =>
      db.insertCategory(key, name, icon);

  @override
  Future<void> removeCategory(String key) async {
    await db.deleteCategoryByKey(key);
    _categoryCtrl.add(await loadCategories());
  }

  @override
  Stream<List<Map<String, String>>> watchCategories() => _categoryCtrl.stream;

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
  Future<void> appendItemsToOrder(String orderId, List<CartItem> items) async {
    await db.appendOrderItems(orderId, items);
    _emitOrders();
  }

  @override
  Future<void> updateOrderItems(String orderId, List<CartItem> items) async {
    await db.replaceOrderItems(orderId, items);
    _emitOrders();
  }

  @override
  Future<void> updateOrderNotes(String orderId, String notes) async {
    await db.updateOrderNotes(orderId, notes);
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
