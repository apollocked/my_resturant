import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class CalendarGrid extends StatelessWidget {
  final int year, month, selectedDay;
  final Set<int> daysWithOrders;
  final ValueChanged<int> onDayTap;
  const CalendarGrid({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDay,
    required this.daysWithOrders,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final first = DateTime(year, month);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final satStartIndex = (first.weekday + 1) % 7;
    final now = DateTime.now();

    final cells = <Widget>[];
    for (int i = 0; i < satStartIndex; i++) {
      cells.add(const SizedBox());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final sel = d == selectedDay;
      final hasOrder = daysWithOrders.contains(d);
      final isFuture = DateTime(year, month, d).isAfter(now);
      cells.add(
        GestureDetector(
          onTap: isFuture ? null : () => onDayTap(d),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$d',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: sel
                        ? Colors.white
                        : (isFuture
                              ? cs.onSurface.withValues(alpha: 0.3)
                              : cs.onSurface),
                  ),
                ),
                if (hasOrder)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: sel ? Colors.white : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    final remaining = (7 - cells.length % 7) % 7;
    for (int i = 0; i < remaining; i++) {
      cells.add(const SizedBox());
    }

    final rows = <Widget>[
      Row(
        children: ['S', 'S', 'M', 'T', 'W', 'T', 'F']
            .map(
              (l) => Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      l,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(
        Row(
          children: cells
              .sublist(i, i + 7)
              .map((c) => Expanded(child: SizedBox(height: 38, child: c)))
              .toList(),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(children: rows),
    );
  }
}
