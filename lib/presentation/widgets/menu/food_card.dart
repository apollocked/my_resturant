import 'package:flutter/material.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/widgets/menu/food_card_body.dart';

class FoodCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onIncrement, onDecrement, onRemove, onLongPress;
  final int quantity;
  final String notes;

  const FoodCard({
    super.key,
    required this.recipe,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
    this.onLongPress,
    this.quantity = 0,
    this.notes = '',
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = quantity > 0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, scale, _) => Transform.scale(
        scale: scale,
        child: FoodCardBody(
          recipe: recipe,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
          onRemove: onRemove,
          onLongPress: onLongPress,
          quantity: quantity,
          notes: notes,
          isSelected: isSelected,
        ),
      ),
    );
  }
}
