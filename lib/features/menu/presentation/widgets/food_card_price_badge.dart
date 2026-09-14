import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class FoodCardPriceBadge extends StatelessWidget {
  const FoodCardPriceBadge({
    super.key,
    required this.label,
    required this.cs,
    required this.padH,
    required this.padV,
    required this.fontSize,
  });

  final String label;
  final ColorScheme cs;
  final double padH;
  final double padV;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 10,
      end: 10,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: fontSize,
            color: cs.onSurface,
          ),
        ),
      ),
    );
  }
}
