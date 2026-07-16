import 'package:my_resturant/domain/entities/cart_item.dart';

enum OrderStatus { pending, preparing, served }

class Order {
  final String id;
  final int tableNumber;
  final String? tableName;
  final List<CartItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final String notes;
  final String trackingCode;

  Order({
    required this.id,
    required this.tableNumber,
    required this.items,
    this.tableName,
    this.status = OrderStatus.pending,
    DateTime? createdAt,
    this.notes = '',
    this.trackingCode = '',
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  String get displayTable => tableName ?? 'Table $tableNumber';

  String get displayTrackingCode => trackingCode.isNotEmpty ? trackingCode : 'ORD-${createdAt.millisecondsSinceEpoch}';

  Order copyWith({OrderStatus? status, String? trackingCode}) {
    return Order(
      id: id,
      tableNumber: tableNumber,
      tableName: tableName,
      items: items,
      status: status ?? this.status,
      createdAt: createdAt,
      notes: notes,
      trackingCode: trackingCode ?? this.trackingCode,
    );
  }
}
