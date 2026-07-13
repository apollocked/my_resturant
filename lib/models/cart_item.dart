import 'package:my_resturant/models/recipe.dart';

class CartItem {
  final Recipe recipe;
  int quantity;
  String notes;

  CartItem({
    required this.recipe,
    this.quantity = 1,
    this.notes = '',
  });

  double get totalPrice => recipe.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'recipe': recipe.toMap(),
      'quantity': quantity,
      'notes': notes,
    };
  }
}
