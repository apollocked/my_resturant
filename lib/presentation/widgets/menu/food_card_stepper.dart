import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class FoodCardStepper extends StatelessWidget {
  const FoodCardStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.cs,
    required this.btnW,
    required this.btnH,
    required this.btnRadius,
    required this.iconSize,
    required this.qtyFont,
    required this.gap,
  });

  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final ColorScheme cs;
  final double btnW;
  final double btnH;
  final double btnRadius;
  final double iconSize;
  final double qtyFont;
  final double gap;

  Widget _btn({required IconData icon, required VoidCallback? onTap}) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: btnW,
        height: btnH,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(btnRadius),
        ),
        child: Icon(icon, size: iconSize, color: cs.onPrimary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(icon: Icons.remove, onTap: onDecrement),
          SizedBox(width: gap),
          Text(
            '$quantity',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: qtyFont,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: gap),
          _btn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}
