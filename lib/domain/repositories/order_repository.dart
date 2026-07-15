import 'dart:async';
import 'package:my_resturant/domain/entities/order_model.dart';

abstract class OrderRepository {
  Future<List<Order>> loadOrders();
  Future<void> saveOrder(Order order);
  Future<void> changeOrderStatus(String id, OrderStatus status);
  Stream<List<Order>> watchOrders();
}
