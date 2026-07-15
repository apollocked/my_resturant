import 'package:flutter/material.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'food_card_image.dart';
import 'food_card_controls.dart';

class FoodCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onIncrement, onDecrement, onLongPress;
  final int quantity;
  final String notes;

  const FoodCard({
    super.key,
    required this.recipe,
    this.onIncrement,
    this.onDecrement,
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
      builder: (context, scale, _) =>
          Transform.scale(scale: scale, child: _CardBody(
            recipe: recipe,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
            onLongPress: onLongPress,
            quantity: quantity,
            notes: notes,
            isSelected: isSelected,
          )),
    );
    }
}

class _CardBody extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onIncrement, onDecrement, onLongPress;
  final int quantity;
  final String notes;
  final bool isSelected;

  const _CardBody({
    required this.recipe,
    this.onIncrement,
    this.onDecrement,
    this.onLongPress,
    required this.quantity,
    required this.notes,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screen = R.screenSize(context);
    final isDesktop = screen == ScreenSize.desktop;
    final isTablet = screen == ScreenSize.tablet;
    final cp = isDesktop ? 20.0 : isTablet ? 16.0 : 12.0;
    final radius = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final nameSize = isDesktop ? 17.0 : isTablet ? 15.0 : 13.0;
    final descSize = isDesktop ? 13.0 : isTablet ? 12.0 : 11.0;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(radius),
        border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          FoodCardImage(
            recipe: recipe,
            quantity: quantity,
            notes: notes,
            onTap: onIncrement,
            onLongPress: onLongPress,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(cp, isDesktop ? 14 : isTablet ? 12 : 10, cp, cp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(recipe.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: nameSize, color: cs.onSurface),
                ),
                const SizedBox(height: 3),
                Text(recipe.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: descSize),
                ),
                SizedBox(height: isDesktop ? 16 : isTablet ? 14 : 10),
                FoodCardControls(
                  quantity: quantity,
                  totalPrice: recipe.price * quantity,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
