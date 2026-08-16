import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/order/order_action_bar.dart';
import 'package:my_resturant/presentation/widgets/order/order_items_list.dart';
import 'package:my_resturant/presentation/widgets/order/order_status_badge.dart';
import 'package:my_resturant/presentation/widgets/order/order_table_row.dart';
import 'package:my_resturant/presentation/widgets/order/order_timeline.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool showTime;
  final bool showTimeline;
  final VoidCallback? onNextStatus;
  final VoidCallback? onReset;
  const OrderCard({
    super.key,
    required this.order,
    this.showTime = false,
    this.showTimeline = false,
    this.onNextStatus,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    final locale = settings.state.locale;
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.screenSize(context) == ScreenSize.desktop;
    final cardPadding = R.cardPadding(context);
    final itemFont = R.fontSm(context);
    final notesFont = R.fontSm(context);

    return Card(
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 18 : 16),
        side: BorderSide(
          color: order.status == OrderStatus.served
              ? cs.outlineVariant
              : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: OrderStatusBadge(
                    status: order.status,
                    locale: locale,
                    showCode:
                        order.trackingCode.isNotEmpty ||
                        order.displayTrackingCode.isNotEmpty,
                    trackingCode: order.displayTrackingCode,
                    isDesktop: isDesktop,
                  ),
                ),
                Flexible(
                  child: OrderTableRow(
                    status: order.status,
                    createdAt: order.createdAt,
                    table: order.displayTable,
                    locale: locale,
                    isDesktop: isDesktop,
                  ),
                ),
              ],
            ),
            if (showTimeline) ...[
              SizedBox(height: isDesktop ? 16.0 : 14.0),
              OrderTimeline(status: order.status, locale: locale),
            ],
            SizedBox(height: isDesktop ? 16.0 : 14.0),
            OrderItemsList(order: order, itemFont: itemFont),
            if (order.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.notes,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: notesFont,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: isDesktop ? 14.0 : 12.0),
            OrderActionBar(
              status: order.status,
              locale: locale,
              total: order.totalPrice,
              clockTime: showTime
                  ? '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}'
                  : null,
              onNextStatus: onNextStatus,
              onReset: onReset,
              isDesktop: isDesktop,
            ),
          ],
        ),
      ),
    );
  }
}
