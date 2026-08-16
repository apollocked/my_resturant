import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class CartItemRemoveButton extends StatelessWidget {
  const CartItemRemoveButton({super.key, required this.onRemove});

  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        onRemove();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.close, size: 16, color: AppColors.error),
      ),
    );
  }
}
