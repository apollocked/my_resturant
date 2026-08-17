import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/widgets/order/order_status_style.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.status, required this.locale});

  final OrderStatus status;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _dot(OrderStatus.served, cs),
              Expanded(child: _line(OrderStatus.served, cs)),
              _dot(OrderStatus.preparing, cs),
              Expanded(child: _line(OrderStatus.preparing, cs)),
              _dot(OrderStatus.pending, cs),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label(context, 'timeline_served', OrderStatus.served, cs),
              _label(context, 'timeline_preparing', OrderStatus.preparing, cs),
              _label(context, 'timeline_pending', OrderStatus.pending, cs),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(OrderStatus s, ColorScheme cs) {
    final reached = s.index <= status.index;
    return Container(
      height: 2,
      color: reached ? OrderStatusStyle.color(s) : cs.outlineVariant,
    );
  }

  Widget _label(
    BuildContext context,
    String key,
    OrderStatus s,
    ColorScheme cs,
  ) {
    final bool active = s == OrderStatus.served
        ? status == OrderStatus.served
        : s == OrderStatus.preparing
        ? status.index >= OrderStatus.preparing.index
        : status == OrderStatus.pending;
    return Text(
      Tr.get(key, locale),
      style: TextStyle(
        fontSize: R.fontSm(context),
        color: active ? OrderStatusStyle.color(s) : cs.onSurfaceVariant,
      ),
    );
  }

  Widget _dot(OrderStatus s, ColorScheme cs) {
    final isReached = s.index <= status.index;
    final c = OrderStatusStyle.color(s);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isReached ? 14 : 10,
      height: isReached ? 14 : 10,
      decoration: BoxDecoration(
        color: isReached ? c : cs.surface,
        shape: BoxShape.circle,
        border: Border.all(color: isReached ? c : cs.outlineVariant, width: 2),
        boxShadow: isReached
            ? [BoxShadow(color: c.withValues(alpha: 0.3), blurRadius: 4)]
            : null,
      ),
      child: isReached ? Icon(Icons.check, size: 8, color: cs.onPrimary) : null,
    );
  }
}
