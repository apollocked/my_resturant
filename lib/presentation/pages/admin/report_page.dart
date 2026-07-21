import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/profile/stat_card.dart';
import 'package:my_resturant/presentation/widgets/shared/shimmer_skeletons.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderCubit>().state;
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final counts = state.dishOrderCounts;
    final maxCount = counts.entries.firstOrNull?.value ?? 1;
    final isDesktop = R.isDesktop(context);
    final p = R.padding(context);

    final today = DateTime.now();
    final weekDays = List.generate(
      7,
      (i) => today.subtract(Duration(days: i)),
    ).reversed.toList();
    final weekData = weekDays.map((d) {
      final orders = state.ordersByDate(d);
      final rev = orders.fold(0.0, (s, o) => s + o.totalPrice);
      return (date: d, count: orders.length, revenue: rev);
    }).toList();
    final maxWeekCount = weekData
        .fold(0, (m, d) => m > d.count ? m : d.count)
        .toDouble();
    final maxWeekRev = weekData.fold(
      0.0,
      (m, d) => m > d.revenue ? m : d.revenue,
    );
    final weekTotalOrders = weekData.fold(0, (s, d) => s + d.count);
    final weekTotalRev = weekData.fold(0.0, (s, d) => s + d.revenue);

    const dayAbbr = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

    return Scaffold(
      appBar: AppBar(title: Text(t('report'))),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: state.isLoading && state.orders.isEmpty
              ? ListView(
                  padding: EdgeInsets.all(p),
                  children: [
                    if (isDesktop)
                      Row(
                        children:
                            List.generate(
                                  3,
                                  (_) => const Expanded(
                                    child: ShimmerBox(
                                      width: double.infinity,
                                      height: 80,
                                      radius: 14,
                                    ),
                                  ),
                                )
                                .expand((w) => [w, const SizedBox(width: 12)])
                                .toList()
                              ..removeLast(),
                      )
                    else ...[
                      const Row(
                        children: [
                          Expanded(
                            child: ShimmerBox(
                              width: double.infinity,
                              height: 80,
                              radius: 14,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ShimmerBox(
                              width: double.infinity,
                              height: 80,
                              radius: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const ShimmerBox(
                        width: double.infinity,
                        height: 80,
                        radius: 14,
                      ),
                    ],
                    const SizedBox(height: 24),
                    const ShimmerBox(width: 140, height: 18, radius: 6),
                    const SizedBox(height: 16),
                    ...List.generate(
                      4,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: ShimmerListTile(),
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: EdgeInsets.all(p),
                  children: [
                    if (isDesktop)
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: Icons.receipt_long,
                              label: t('cart'),
                              value: '${state.totalOrders}',
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              icon: Icons.attach_money,
                              label: t('revenue'),
                              value:
                                  '${state.totalRevenue.toInt()} ${t('currency_suffix')}',
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              icon: Icons.star,
                              label: t('most_ordered'),
                              value: state.mostOrderedDish ?? '-',
                              sub: state.totalOrders > 0
                                  ? '${state.mostOrderedDishCount} ${t('times')}'
                                  : null,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: Icons.receipt_long,
                              label: t('cart'),
                              value: '${state.totalOrders}',
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              icon: Icons.attach_money,
                              label: t('revenue'),
                              value:
                                  '${state.totalRevenue.toInt()} ${t('currency_suffix')}',
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: Icons.star,
                              label: t('most_ordered'),
                              value: state.mostOrderedDish ?? '-',
                              sub: state.totalOrders > 0
                                  ? '${state.mostOrderedDishCount} ${t('times')}'
                                  : null,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (weekTotalOrders > 0) ...[
                      Text(
                        t('weekly_report'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 200,
                                child: _OrdersChart(
                                  weekData: weekData,
                                  maxValue: maxWeekCount,
                                  dayAbbr: dayAbbr,
                                  cs: cs,
                                  isDesktop: isDesktop,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 200,
                                child: _RevenueChart(
                                  weekData: weekData,
                                  maxValue: maxWeekRev,
                                  dayAbbr: dayAbbr,
                                  cs: cs,
                                  isDesktop: isDesktop,
                                ),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        SizedBox(
                          height: 180,
                          child: _OrdersChart(
                            weekData: weekData,
                            maxValue: maxWeekCount,
                            dayAbbr: dayAbbr,
                            cs: cs,
                            isDesktop: isDesktop,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: _RevenueChart(
                            weekData: weekData,
                            maxValue: maxWeekRev,
                            dayAbbr: dayAbbr,
                            cs: cs,
                            isDesktop: isDesktop,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t('week_total'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '$weekTotalOrders ${t('orders')}  •  ${weekTotalRev.toStringAsFixed(0)} ${t('currency_suffix')}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (counts.isNotEmpty) ...[
                      Text(
                        t('foods_ranking'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...counts.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '${e.value}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: e.value / maxCount,
                                    backgroundColor: cs.outlineVariant,
                                    color: AppColors.primary,
                                    minHeight: isDesktop ? 10 : 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 100,
                                child: Text(
                                  e.key,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: isDesktop ? 14 : 12,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _OrdersChart extends StatelessWidget {
  final List<({DateTime date, int count, double revenue})> weekData;
  final double maxValue;
  final List<String> dayAbbr;
  final ColorScheme cs;
  final bool isDesktop;
  const _OrdersChart({
    required this.weekData,
    required this.maxValue,
    required this.dayAbbr,
    required this.cs,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${Tr.get('total_orders', locale)} (${Tr.get('daily', locale)})',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue > 0 ? maxValue * 1.2 : 1,
              barGroups: weekData.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: d.count.toDouble(),
                      color: AppColors.primary,
                      width: isDesktop ? 18 : 14,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= weekData.length) {
                        return const SizedBox();
                      }
                      final wd = weekData[i].date.weekday;
                      return Text(
                        dayAbbr[wd == 7 ? 0 : wd],
                        style: TextStyle(
                          fontSize: 10,
                          color: cs.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxValue > 0 ? (maxValue * 1.2 / 4) : 1,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: cs.outlineVariant.withValues(alpha: 0.3),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (g, _, rod, _) => BarTooltipItem(
                    '${rod.toY.toInt()} ${Tr.get('orders', locale)}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<({DateTime date, int count, double revenue})> weekData;
  final double maxValue;
  final List<String> dayAbbr;
  final ColorScheme cs;
  final bool isDesktop;
  const _RevenueChart({
    required this.weekData,
    required this.maxValue,
    required this.dayAbbr,
    required this.cs,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${Tr.get('daily_revenue', locale)} (${Tr.get('daily', locale)})',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue > 0 ? maxValue * 1.2 : 1,
              barGroups: weekData.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: d.revenue,
                      color: Colors.green,
                      width: isDesktop ? 18 : 14,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= weekData.length) {
                        return const SizedBox();
                      }
                      final wd = weekData[i].date.weekday;
                      return Text(
                        dayAbbr[wd == 7 ? 0 : wd],
                        style: TextStyle(
                          fontSize: 10,
                          color: cs.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxValue > 0 ? (maxValue * 1.2 / 4) : 1,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: cs.outlineVariant.withValues(alpha: 0.3),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (g, _, rod, _) => BarTooltipItem(
                    '${rod.toY.toStringAsFixed(0)} ${Tr.get('currency_suffix', locale)}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
