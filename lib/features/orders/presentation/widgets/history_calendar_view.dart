import 'package:flutter/material.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';
import 'package:my_resturant/features/orders/presentation/widgets/calendar_grid.dart';
import 'package:my_resturant/features/orders/presentation/widgets/history_month_nav.dart';
import 'package:my_resturant/features/orders/presentation/widgets/history_stats_bar.dart';

/// Month calendar + day stats block on the order history page.
class HistoryCalendarView extends StatelessWidget {
  final String Function(String) t;
  final DateTime viewMonth;
  final DateTime selectedDate;
  final List<Order> orders;
  final void Function(int) onDayTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPick;
  final double hPad;

  const HistoryCalendarView({
    super.key,
    required this.t,
    required this.viewMonth,
    required this.selectedDate,
    required this.orders,
    required this.onDayTap,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
    required this.hPad,
  });

  @override
  Widget build(BuildContext context) {
    final dayOrders = orders
        .where(
          (o) =>
              o.createdAt.year == selectedDate.year &&
              o.createdAt.month == selectedDate.month &&
              o.createdAt.day == selectedDate.day,
        )
        .toList();
    final daysWithOrders = orders
        .where(
          (o) =>
              o.createdAt.year == viewMonth.year &&
              o.createdAt.month == viewMonth.month,
        )
        .map((o) => o.createdAt.day)
        .toSet();
    final dayTotal = dayOrders
        .where((o) => o.status != OrderStatus.cancelled)
        .fold(0.0, (s, o) => s + o.totalPrice);
    final dayItems = dayOrders
        .where((o) => o.status != OrderStatus.cancelled)
        .fold(0, (s, o) => s + o.items.fold(0, (si, i) => si + i.quantity));

    return Column(
      children: [
        HistoryMonthNav(
          t: t,
          year: viewMonth.year,
          month: viewMonth.month,
          onPrev: onPrev,
          onNext: onNext,
          onPick: onPick,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: CalendarGrid(
            year: viewMonth.year,
            month: viewMonth.month,
            selectedDay: selectedDate.day,
            daysWithOrders: daysWithOrders,
            onDayTap: onDayTap,
          ),
        ),
        const Divider(height: 1),
        HistoryStatsBar(
          orderCount: dayOrders.length,
          itemCount: dayItems,
          total: dayTotal,
          t: t,
        ),
      ],
    );
  }
}