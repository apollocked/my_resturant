import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_action_bar.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_items_list.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_status_badge.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_status_style.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_table_row.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_timeline.dart';

class OrderCard extends StatefulWidget {
  final Order order;
  final bool showTime;
  final bool showTimeline;
  final VoidCallback? onNextStatus;
  final VoidCallback? onReset;
  final VoidCallback? onCancel;
  const OrderCard({
    super.key,
    required this.order,
    this.showTime = false,
    this.showTimeline = false,
    this.onNextStatus,
    this.onReset,
    this.onCancel,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  OrderStatus? _prevStatus;

  @override
  void didUpdateWidget(covariant OrderCard old) {
    super.didUpdateWidget(old);
    if (_prevStatus != widget.order.status) {
      _prevStatus = widget.order.status;
      _pulse.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    final locale = settings.state.locale;
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.screenSize(context) == ScreenSize.desktop;
    final cardPadding = R.cardPadding(context);
    final itemFont = R.fontSm(context);
    final notesFont = R.fontSm(context);
    final statusColor = OrderStatusStyle.color(widget.order.status);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = _pulse.value;
        final scale = 1 + 0.014 * math.sin(math.pi * t);
        final glow = (1 - t) * 0.22;
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isDesktop ? 18 : 16),
              border: Border.all(
                color: statusColor.withValues(alpha: glow),
                width: 1.6,
              ),
            ),
            child: child,
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: isDesktop ? 0 : 10),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 18 : 16),
          side: BorderSide(
            color: widget.order.status == OrderStatus.served
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
                      status: widget.order.status,
                      locale: locale,
                      showCode:
                          widget.order.trackingCode.isNotEmpty ||
                          widget.order.displayTrackingCode.isNotEmpty,
                      trackingCode: widget.order.displayTrackingCode,
                      isDesktop: isDesktop,
                    ),
                  ),
                  Flexible(
                    child: OrderTableRow(
                      status: widget.order.status,
                      createdAt: widget.order.createdAt,
                      table: widget.order.displayTable,
                      locale: locale,
                      isDesktop: isDesktop,
                    ),
                  ),
                ],
              ),
              if (widget.showTimeline) ...[
                SizedBox(height: isDesktop ? 16.0 : 14.0),
                OrderTimeline(status: widget.order.status, locale: locale),
              ],
              SizedBox(height: isDesktop ? 16.0 : 14.0),
              OrderItemsList(order: widget.order, itemFont: itemFont),
              if (widget.order.notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.order.notes,
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
                status: widget.order.status,
                locale: locale,
                total: widget.order.totalPrice,
                clockTime: widget.showTime
                    ? '${widget.order.createdAt.hour.toString().padLeft(2, '0')}:${widget.order.createdAt.minute.toString().padLeft(2, '0')}'
                    : null,
                onNextStatus: widget.onNextStatus,
                onReset: widget.onReset,
                onCancel: widget.onCancel,
                isDesktop: isDesktop,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
