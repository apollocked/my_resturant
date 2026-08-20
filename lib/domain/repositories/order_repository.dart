import 'dart:async';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/order_model.dart';

abstract class OrderRepository {
  Future<List<Order>> loadOrders();
  Future<void> saveOrder(Order order);
  Future<void> changeOrderStatus(String id, OrderStatus status);
  Future<void> appendItemsToOrder(String orderId, List<CartItem> items);
  Future<void> updateOrderItems(String orderId, List<CartItem> items);
  Future<void> updateOrderNotes(String orderId, String notes);
  Future<void> deleteAllOrders();
  Stream<List<Order>> watchOrders();
}
