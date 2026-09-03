import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/widgets/orders/history_order_list.dart';
import 'package:my_resturant/presentation/widgets/orders/history_shimmer.dart';

class HistoryLayout extends StatelessWidget {
  final Widget calendar;
  final bool loading;
  final bool isEmpty;
  final List<Order> dayOrders;
  final String Function(String) t;
  final double padding;
  final Color outlineVariant;
  const HistoryLayout({
    super.key,
    required this.calendar,
    required this.loading,
    required this.isEmpty,
    required this.dayOrders,
    required this.t,
    required this.padding,
    required this.outlineVariant,
  });

  @override
  Widget build(BuildContext context) {
    if (loading && isEmpty) {
      return HistoryShimmer(padding: padding);
    }
    final orderList = Expanded(
      child: HistoryOrderList(orders: dayOrders, t: t),
    );
    if (!R.isPhone(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: calendar,
            ),
          ),
          VerticalDivider(width: 1, color: outlineVariant),
          orderList,
        ],
      );
    }
    return Column(
      children: [
        calendar,
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 8),
        orderList,
      ],
    );
  }
}
