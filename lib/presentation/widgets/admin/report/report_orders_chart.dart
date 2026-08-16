import 'package:flutter/material.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/widgets/admin/report/report_charts.dart';

class OrdersChart extends StatelessWidget {
  const OrdersChart({super.key, required this.weekData});

  final List<ReportDay> weekData;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return ReportBarChart(
      title: '${Tr.get('total_orders', locale)} (${Tr.get('daily', locale)})',
      weekData: weekData,
      toY: (d) => d.count.toDouble(),
      tooltip: (v) => '${v.toInt()} ${Tr.get('orders', locale)}',
      barColor: AppColors.primary,
    );
  }
}
