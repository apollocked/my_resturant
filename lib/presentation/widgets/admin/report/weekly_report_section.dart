import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/widgets/admin/report/report_charts.dart';
import 'package:my_resturant/presentation/widgets/admin/report/report_orders_chart.dart';
import 'package:my_resturant/presentation/widgets/admin/report/report_revenue_chart.dart';

class WeeklyReportSection extends StatelessWidget {
  const WeeklyReportSection({
    super.key,
    required this.weekData,
    required this.weekTotalOrders,
    required this.weekTotalRev,
    required this.isDesktop,
    required this.t,
  });

  final List<ReportDay> weekData;
  final int weekTotalOrders;
  final double weekTotalRev;
  final bool isDesktop;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final chartSize = isDesktop ? 200.0 : 180.0;
    final charts = [
      SizedBox(
        height: chartSize,
        child: OrdersChart(weekData: weekData),
      ),
      SizedBox(
        height: chartSize,
        child: RevenueChart(weekData: weekData),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('weekly_report'),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: R.fontLg(context),
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: charts[0]),
              const SizedBox(width: 16),
              Expanded(child: charts[1]),
            ],
          )
        else ...[
          charts[0],
          const SizedBox(height: 16),
          charts[1],
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('week_total'),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: R.fontSm(context),
                ),
              ),
              Flexible(
                child: Text(
                  '$weekTotalOrders ${t('orders')}  \u2022  ${weekTotalRev.toStringAsFixed(0)} ${t('currency_suffix')}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: R.fontSm(context),
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
