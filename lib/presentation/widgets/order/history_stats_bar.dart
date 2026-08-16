import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/widgets/order/stat_chip.dart';

class HistoryStatsBar extends StatelessWidget {
  const HistoryStatsBar({
    super.key,
    required this.orderCount,
    required this.itemCount,
    required this.total,
    required this.t,
  });

  final int orderCount;
  final int itemCount;
  final double total;
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.padding(context),
        vertical: 8,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          StatChip(
            icon: Icons.receipt_long,
            label: '$orderCount ${t('orders')}',
            color: AppColors.primary,
          ),
          StatChip(
            icon: Icons.shopping_bag,
            label: '$itemCount ${t('total_items')}',
            color: cs.tertiary,
          ),
          StatChip(
            icon: Icons.attach_money,
            label: '${total.toStringAsFixed(0)} ${t('currency_suffix')}',
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
