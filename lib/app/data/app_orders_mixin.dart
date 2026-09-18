import 'package:flutter/foundation.dart';
import 'package:my_resturant/features/orders/domain/entities/cart_item.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';
import 'package:my_resturant/app/data/app_repository.dart';
import 'package:my_resturant/app/data/datasources/local/app_database.dart';

mixin AppOrdersRepoMixin on AppRepositoryBase {
  Future<void> _emitOrders() async {
    try {
      streams.orders.add(await loadOrders());
    } catch (e) {
      debugPrint('AppRepository._emitOrders error: $e');
    }
  }

  Future<List<Order>> loadOrders() => db.getAllOrders();

  Future<void> saveOrder(Order order) async {
    await db.insertOrder(order);
    _emitOrders();
  }

  Future<void> changeOrderStatus(String id, OrderStatus status) async {
    await db.updateOrderStatusRecord(id, status);
    _emitOrders();
  }

  Future<void> appendItemsToOrder(String orderId, List<CartItem> items) async {
    await db.appendOrderItems(orderId, items);
    _emitOrders();
  }

  Future<void> updateOrderItems(String orderId, List<CartItem> items) async {
    await db.replaceOrderItems(orderId, items);
    _emitOrders();
  }

  Future<void> updateOrderNotes(String orderId, String notes) async {
    await db.updateOrderNotes(orderId, notes);
    _emitOrders();
  }

  Future<void> deleteAllOrders() async {
    await db.deleteAllOrders();
    _emitOrders();
  }

  Stream<List<Order>> watchOrders() => streams.orders.stream;
}