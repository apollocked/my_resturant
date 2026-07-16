import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:my_resturant/data/datasources/local/tables.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/order_model.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Recipes, Categories, Orders, OrderItems, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
    },
  );

  Future<void> _seed() async {
    final recipeRows = [
      ('1', 'بەرگری چیزبۆرگەر', 'https://picsum.photos/seed/cheeseburger/400/300', 8500.0, 'بەرگری تایبەت و دەبڵ پەنیر', 'burger'),
      ('2', 'پیتزا مۆتزاریلا', 'https://picsum.photos/seed/pizza/400/300', 12000.0, 'پیتزای مۆتزاریلا و تەرخان', 'pizza'),
      ('3', 'شاورمە دەبڵ', 'https://picsum.photos/seed/shawarma/400/300', 7000.0, 'شاورمەی دەبڵ بە تەرخان و سەلەتە', 'shawarma'),
      ('4', 'کەبابی کۆیندە', 'https://picsum.photos/seed/kebab/400/300', 15000.0, 'کەبابی کۆیندە بە برژاو', 'shawarma'),
      ('5', 'بەرگری کلاسیک', 'https://picsum.photos/seed/burger/400/300', 6500.0, 'بەرگری کلاسیک بە پەنیر و کەچەپ', 'burger'),
      ('6', 'زەنگیانەی مریشک', 'https://picsum.photos/seed/chicken-sandwich/400/300', 5500.0, 'زەنگیانەی مریشکی بە تایبەت', 'chicken'),
      ('7', 'فەرجی مریشک', 'https://picsum.photos/seed/fried-chicken/400/300', 9500.0, 'فەرجی مریشکی خوایی بە سۆس', 'chicken'),
      ('8', 'دۆنەر کێباب', 'https://picsum.photos/seed/doner/400/300', 8000.0, 'دۆنەر کێباب بە نانی تایبەت', 'shawarma'),
      ('9', 'سەلەتە کێزەر', 'https://picsum.photos/seed/salad/400/300', 4500.0, 'سەلەتەی کێزەری تازە', 'salad'),
      ('10', 'فەرجی سوشی', 'https://picsum.photos/seed/sushi/400/300', 11000.0, 'فەرجی سوشی بە تایبەت', 'salad'),
      ('11', 'پاستا ئەلفرێدۆ', 'https://picsum.photos/seed/pasta/400/300', 10000.0, 'پاستا ئەلفرێدۆ بە مریشک', 'pizza'),
      ('12', 'لەحمی عەجین', 'https://picsum.photos/seed/lahmacun/400/300', 5000.0, 'لەحمی عەجینی تایبەت', 'pizza'),
    ];
    for (final r in recipeRows) {
      await into(recipes).insert(RecipesCompanion.insert(
        id: r.$1, name: r.$2, imageUrl: r.$3, price: r.$4, description: r.$5, category: r.$6,
      ));
    }

    final catRows = [
      ('all', 'هەموو', '🍽'),
      ('burger', 'بەرگر', '🍔'),
      ('pizza', 'پیتزا', '🍕'),
      ('shawarma', 'شاورمە', '🌯'),
      ('chicken', 'مریشک', '🍗'),
      ('salad', 'سەلەتە', '🥗'),
    ];
    for (final c in catRows) {
      await into(categories).insert(CategoriesCompanion.insert(key: c.$1, name: c.$2, icon: c.$3));
    }
  }

  Future<List<Recipe>> getAllRecipes() async {
    final rows = await select(recipes).get();
    return rows.map((r) => Recipe(
      id: r.id, name: r.name, imageUrl: r.imageUrl, price: r.price,
      description: r.description, category: r.category, available: r.available,
    )).toList();
  }

  Future<Recipe?> getRecipeById(String id) async {
    final r = await (select(recipes)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (r == null) return null;
    return Recipe(id: r.id, name: r.name, imageUrl: r.imageUrl, price: r.price,
      description: r.description, category: r.category, available: r.available);
  }

  Future<void> insertRecipe(Recipe recipe) async {
    await into(recipes).insert(RecipesCompanion.insert(
      id: recipe.id, name: recipe.name, imageUrl: recipe.imageUrl,
      price: recipe.price, description: recipe.description,
      category: recipe.category, available: Value(recipe.available),
    ));
  }

  Future<void> updateRecipeRecord(String id, {String? name, double? price, String? category, String? description}) async {
    await (update(recipes)..where((t) => t.id.equals(id))).write(RecipesCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      price: price != null ? Value(price) : const Value.absent(),
      category: category != null ? Value(category) : const Value.absent(),
      description: description != null ? Value(description) : const Value.absent(),
    ));
  }

  Future<void> deleteRecipeRecord(String id) async {
    await (delete(recipes)..where((t) => t.id.equals(id))).go();
  }

  Future<void> toggleRecipeAvailability(String id) async {
    final r = await (select(recipes)..where((t) => t.id.equals(id))).getSingle();
    await (update(recipes)..where((t) => t.id.equals(id))).write(RecipesCompanion(available: Value(!r.available)));
  }

  Future<List<Map<String, String>>> getAllCategoryMaps() async {
    final rows = await select(categories).get();
    return rows.map((c) => {'key': c.key, 'name': c.name, 'icon': c.icon}).toList();
  }

  Future<void> insertCategory(String key, String name, String icon) async {
    await into(categories).insert(CategoriesCompanion.insert(key: key, name: name, icon: icon));
  }

  Future<void> deleteCategoryByKey(String key) async {
    await (delete(categories)..where((t) => t.key.equals(key))).go();
  }

  Future<List<Order>> getAllOrders() async {
    final rows = await (select(orders)..orderBy([(o) => OrderingTerm(expression: o.createdAt, mode: OrderingMode.desc)])).get();
    final itemsByOrder = <String, List<CartItem>>{};
    final allItems = await select(orderItems).get();
    for (final item in allItems) {
      final recipe = await getRecipeById(item.recipeId);
      if (recipe == null) continue;
      itemsByOrder.putIfAbsent(item.orderId, () => []).add(CartItem(recipe: recipe, quantity: item.quantity, notes: item.notes));
    }
    return rows.map((o) => Order(
      id: o.id, tableNumber: o.tableNumber, tableName: o.tableLabel,
      items: itemsByOrder[o.id] ?? [],
      status: OrderStatus.values.firstWhere((s) => s.name == o.status),
      createdAt: DateTime.fromMillisecondsSinceEpoch(o.createdAt),
      notes: o.notes,
    )).toList();
  }

  Future<void> insertOrder(Order order) async {
    await into(orders).insert(OrdersCompanion.insert(
      id: order.id, tableNumber: order.tableNumber, tableLabel: Value(order.tableName),
      status: order.status.name, createdAt: order.createdAt.millisecondsSinceEpoch, notes: order.notes,
    ));
    for (final item in order.items) {
      await into(orderItems).insert(OrderItemsCompanion.insert(
        orderId: order.id, recipeId: item.recipe.id, quantity: item.quantity, notes: item.notes,
      ));
    }
  }

  Future<void> updateOrderStatusRecord(String orderId, OrderStatus status) async {
    await (update(orders)..where((t) => t.id.equals(orderId))).write(OrdersCompanion(status: Value(status.name)));
  }

  Future<void> deleteAllOrders() async {
    await delete(orderItems).go();
    await delete(orders).go();
  }

  Future<Map<String, String>> getSettings() async {
    final rows = await select(appSettings).get();
    return {for (final r in rows) r.key: r.value};
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insert(SettingRecord(key: key, value: value), mode: InsertMode.insertOrReplace);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    await Directory(dir.path).create(recursive: true);
    return NativeDatabase(File(p.join(dir.path, 'restaurant.db')));
  });
}
