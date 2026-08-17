import 'package:flutter/material.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/widgets/admin/report/report_charts.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key, required this.weekData});

  final List<ReportDay> weekData;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return ReportBarChart(
      title: '${Tr.get('daily_revenue', locale)} (${Tr.get('daily', locale)})',
      weekData: weekData,
      toY: (d) => d.revenue,
      tooltip: (v) =>
          '${v.toStringAsFixed(0)} ${Tr.get('currency_suffix', locale)}',
      barColor: AppColors.success,
    );
  }
}
