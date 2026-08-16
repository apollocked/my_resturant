import 'package:flutter/material.dart';

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
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
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
