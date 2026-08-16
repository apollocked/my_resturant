import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/widgets/profile/stat_card.dart';

class ReportStats extends StatelessWidget {
  const ReportStats({
    super.key,
    required this.isDesktop,
    required this.totalOrders,
    required this.totalRevenue,
    required this.mostOrderedDish,
    required this.mostOrderedCount,
    required this.t,
  });

  final bool isDesktop;
  final int totalOrders;
  final double totalRevenue;
  final String? mostOrderedDish;
  final int mostOrderedCount;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final revenue = '${totalRevenue.toInt()} ${t('currency_suffix')}';
    final ordersCard = StatCard(
      icon: Icons.receipt_long,
      label: t('cart'),
      value: '$totalOrders',
      color: AppColors.primary,
    );
    final revenueCard = StatCard(
      icon: Icons.attach_money,
      label: t('revenue'),
      value: revenue,
      color: AppColors.success,
    );
    final mostOrderedCard = StatCard(
      icon: Icons.star,
      label: t('most_ordered'),
      value: mostOrderedDish ?? '-',
      sub: totalOrders > 0 ? '$mostOrderedCount ${t('times')}' : null,
      color: AppColors.warning,
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: ordersCard),
          const SizedBox(width: 12),
          Expanded(child: revenueCard),
          const SizedBox(width: 12),
          Expanded(child: mostOrderedCard),
        ],
      );
    }
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: ordersCard),
            const SizedBox(width: 12),
            Expanded(child: revenueCard),
          ],
        ),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: mostOrderedCard)]),
      ],
    );
  }
}
