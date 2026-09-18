import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

/// Non-editable quantity chip shown on order detail line items.
class OrderQtyBadge extends StatelessWidget {
  final int quantity;

  const OrderQtyBadge({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '\u00d7$quantity',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: R.fontSm(context),
          color: AppColors.primary,
        ),
      ),
    );
  }
}