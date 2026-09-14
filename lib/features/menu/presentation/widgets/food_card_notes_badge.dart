import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class FoodCardNotesBadge extends StatelessWidget {
  const FoodCardNotesBadge({super.key, required this.cs, required this.size});

  final ColorScheme cs;
  final double size;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      bottom: 10,
      end: 10,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.edit_note, size: size, color: AppColors.primary),
      ),
    );
  }
}
