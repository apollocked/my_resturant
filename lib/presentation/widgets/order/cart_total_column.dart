import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class CartTotalColumn extends StatelessWidget {
  const CartTotalColumn({
    super.key,
    required this.total,
    required this.currencySuffix,
    required this.totalLabel,
    required this.cs,
  });

  final double total;
  final String currencySuffix;
  final String totalLabel;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${total.toInt()} $currencySuffix',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: R.fontXl(context),
            color: AppColors.primary,
          ),
        ),
        Text(
          totalLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: R.fontSm(context),
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
