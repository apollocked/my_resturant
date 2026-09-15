import 'package:my_resturant/features/orders/domain/entities/cart_item.dart';

class CartDraft {
  final List<CartItem> items;
  final int selectedTable;
  final Map<String, String> pendingNotes;
  final DateTime createdAt;

  CartDraft({
    required this.items,
    required this.selectedTable,
    required this.pendingNotes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}