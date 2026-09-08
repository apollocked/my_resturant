import 'package:my_resturant/domain/entities/recipe.dart';

class CartItem {
  final Recipe recipe;
  int quantity;
  String notes;

  CartItem({required this.recipe, this.quantity = 1, this.notes = ''});

  double get totalPrice => recipe.price * quantity;

  Map<String, dynamic> toMap() {
    return {'recipe': recipe.toMap(), 'quantity': quantity, 'notes': notes};
  }

  factory CartItem.fromMap(Map<String, dynamic> m) {
    return CartItem(
      recipe: Recipe.fromMap((m['recipe'] as Map).cast<String, dynamic>()),
      quantity: (m['quantity'] as num?)?.toInt() ?? 1,
      notes: m['notes'] as String? ?? '',
    );
  }
}
