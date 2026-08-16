import 'package:drift/drift.dart';
import 'package:my_resturant/data/datasources/local/app_database.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/entities/recipe.dart';

extension AppDatabaseOrderQueries on AppDatabase {
  Future<List<Order>> getAllOrders() async {
    final rows =
        await (select(orders)..orderBy([
              (o) => OrderingTerm(
                expression: o.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
            .get();
    final recipeById = {for (final r in await select(recipes).get()) r.id: r};
    final itemsByOrder = <String, List<CartItem>>{};
    final allItems = await select(orderItems).get();
    for (final item in allItems) {
      final row = recipeById[item.recipeId];
      if (row == null) continue;
      itemsByOrder
          .putIfAbsent(item.orderId, () => [])
          .add(
            CartItem(
              recipe: Recipe(
                id: row.id,
                name: row.name,
                imageUrl: row.imageUrl,
                price: row.price,
                description: row.description,
                category: row.category,
                available: row.available,
              ),
              quantity: item.quantity,
              notes: item.notes,
            ),
          );
    }
    return rows
        .map(
          (o) => Order(
            id: o.id,
            tableNumber: o.tableNumber,
            tableName: o.tableLabel,
            items: itemsByOrder[o.id] ?? [],
            status: OrderStatus.values.firstWhere(
              (s) => s.name == o.status,
              orElse: () => OrderStatus.pending,
            ),
            createdAt: DateTime.fromMillisecondsSinceEpoch(o.createdAt),
            notes: o.notes,
          ),
        )
        .toList();
  }

  Future<void> insertOrder(Order order) async {
    await into(orders).insert(
      OrdersCompanion.insert(
        id: order.id,
        tableNumber: order.tableNumber,
        tableLabel: Value(order.tableName),
        status: order.status.name,
        createdAt: order.createdAt.millisecondsSinceEpoch,
        notes: order.notes,
      ),
    );
    for (final item in order.items) {
      await into(orderItems).insert(
        OrderItemsCompanion.insert(
          orderId: order.id,
          recipeId: item.recipe.id,
          quantity: item.quantity,
          notes: item.notes,
        ),
      );
    }
  }

  Future<void> updateOrderStatusRecord(
    String orderId,
    OrderStatus status,
  ) async {
    await (update(orders)..where((t) => t.id.equals(orderId))).write(
      OrdersCompanion(status: Value(status.name)),
    );
  }

  Future<void> appendOrderItems(String orderId, List<CartItem> items) async {
    final order = await (select(
      orders,
    )..where((t) => t.id.equals(orderId))).getSingleOrNull();
    if (order == null) return;
    for (final item in items) {
      await into(orderItems).insert(
        OrderItemsCompanion.insert(
          orderId: orderId,
          recipeId: item.recipe.id,
          quantity: item.quantity,
          notes: item.notes,
        ),
      );
    }
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
    await into(appSettings).insert(
      SettingRecord(key: key, value: value),
      mode: InsertMode.insertOrReplace,
    );
  }
}
