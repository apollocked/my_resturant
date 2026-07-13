import 'package:my_resturant/models/cart_item.dart';

enum OrderStatus { pending, preparing, served }

class Order {
  final String id;
  final int tableNumber;
  final List<CartItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final String notes;

  Order({
    required this.id,
    required this.tableNumber,
    required this.items,
    this.status = OrderStatus.pending,
    DateTime? createdAt,
    this.notes = '',
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      tableNumber: tableNumber,
      items: items,
      status: status ?? this.status,
      createdAt: createdAt,
      notes: notes,
    );
  }
}
