import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class FoodCardAddButton extends StatelessWidget {
  const FoodCardAddButton({
    super.key,
    required this.label,
    required this.onAdd,
    required this.cs,
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.radius,
  });

  final String label;
  final VoidCallback? onAdd;
  final ColorScheme cs;
  final double height;
  final double fontSize;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onAdd?.call();
      },
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: cs.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: iconSize),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
