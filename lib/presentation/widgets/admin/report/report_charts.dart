import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';

class ReportDay {
  const ReportDay({
    required this.date,
    required this.count,
    required this.revenue,
  });

  final DateTime date;
  final int count;
  final double revenue;
}

List<String> reportDayAbbr(Locale locale) => [
  Tr.get('day_sat', locale),
  Tr.get('day_sun', locale),
  Tr.get('day_mon', locale),
  Tr.get('day_tue', locale),
  Tr.get('day_wed', locale),
  Tr.get('day_thu', locale),
  Tr.get('day_fri', locale),
];

class ReportBarChart extends StatelessWidget {
  const ReportBarChart({
    super.key,
    required this.title,
    required this.weekData,
    required this.toY,
    required this.tooltip,
    required this.barColor,
  });

  final String title;
  final List<ReportDay> weekData;
  final double Function(ReportDay day) toY;
  final String Function(double value) tooltip;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final isDesktop = R.isDesktop(context);
    final maxValue = weekData.fold(0.0, (m, d) {
      final v = toY(d);
      return m > v ? m : v;
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
              barGroups: [
                for (var i = 0; i < weekData.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: toY(weekData[i]),
                        color: barColor,
                        width: isDesktop ? 18 : 14,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
              ],
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
                      return Text(
                        reportDayAbbr(locale)[
                            (weekData[i].date.weekday + 1) % 7],
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
                horizontalInterval: maxValue > 0 ? maxValue * 1.2 / 4 : 1,
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
                    tooltip(rod.toY),
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
