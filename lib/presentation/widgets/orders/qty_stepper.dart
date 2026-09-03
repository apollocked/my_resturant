import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
  });
  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onChanged(quantity - 1),
            child: Icon(
              quantity <= 1 ? Icons.delete_outline : Icons.remove,
              size: 18,
              color: quantity <= 1 ? cs.error : AppColors.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$quantity',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: R.fontSm(context),
                color: AppColors.primary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(quantity + 1),
            child: const Icon(Icons.add, size: 18, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
