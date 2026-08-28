import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/admin/report/foods_ranking.dart';
import 'package:my_resturant/presentation/widgets/admin/report/report_charts.dart';
import 'package:my_resturant/presentation/widgets/admin/report/report_shimmer.dart';
import 'package:my_resturant/presentation/widgets/admin/report/report_stats.dart';
import 'package:my_resturant/presentation/widgets/admin/report/weekly_report_section.dart';
import 'package:my_resturant/shared/empty_state.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderCubit>().state;
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final isWide = !R.isPhone(context);
    final p = R.padding(context);

    final today = DateTime.now();
    final weekData = List.generate(7, (i) => today.subtract(Duration(days: i)))
        .reversed
        .map((d) {
          final orders = state.ordersByDate(d);
          final rev = orders.fold(0.0, (s, o) => s + o.totalPrice);
          return ReportDay(date: d, count: orders.length, revenue: rev);
        })
        .toList();
    final weekTotalOrders = weekData.fold(0, (s, d) => s + d.count);
    final weekTotalRev = weekData.fold(0.0, (s, d) => s + d.revenue);

    final weekly = WeeklyReportSection(
      weekData: weekData,
      weekTotalOrders: weekTotalOrders,
      weekTotalRev: weekTotalRev,
      isDesktop: isWide,
      t: t,
    );
    final ranking = state.dishOrderCounts.isNotEmpty
        ? FoodsRanking(counts: state.dishOrderCounts, t: t)
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(t('report'))),
      body: SafeArea(
        child: state.isLoading && state.orders.isEmpty
            ? const ReportShimmer()
            : state.orders.isEmpty
            ? EmptyState(
                icon: Icons.analytics_outlined,
                title: t('report_empty'),
                subtitle: t('report_empty_subtitle'),
              )
            : ListView(
                padding: EdgeInsets.all(p),
                children: [
                  ReportStats(
                    isDesktop: isWide,
                    totalOrders: state.totalOrders,
                    totalRevenue: state.totalRevenue,
                    mostOrderedDish: state.mostOrderedDish,
                    mostOrderedCount: state.mostOrderedDishCount,
                    t: t,
                  ),
                  const SizedBox(height: 24),
                  if (weekTotalOrders > 0 &&
                      isWide &&
                      ranking != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: weekly),
                        const SizedBox(width: 24),
                        Expanded(child: ranking),
                      ],
                    )
                  else ...[
                    if (weekTotalOrders > 0) ...[
                      weekly,
                      const SizedBox(height: 24),
                    ],
                    ?ranking,
                  ],
                ],
              ),
      ),
    );
  }
}
