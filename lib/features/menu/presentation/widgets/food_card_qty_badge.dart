import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class FoodCardQtyBadge extends StatelessWidget {
  const FoodCardQtyBadge({
    super.key,
    required this.quantity,
    required this.cs,
    required this.size,
    required this.fontSize,
  });

  final int quantity;
  final ColorScheme cs;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 10,
      start: 10,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '$quantity',
          style: TextStyle(
            color: cs.onPrimary,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
