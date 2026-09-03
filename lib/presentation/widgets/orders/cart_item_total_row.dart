import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/widgets/orders/quantity_selector.dart';

class CartItemTotalRow extends StatelessWidget {
  const CartItemTotalRow({
    super.key,
    required this.total,
    required this.totalLabel,
    required this.fontSize,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final double total;
  final String totalLabel;
  final double fontSize;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            '${total.toInt()} $totalLabel',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        QuantitySelector(quantity: quantity, onChanged: onQuantityChanged),
      ],
    );
  }
}
