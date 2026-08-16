import 'package:flutter/material.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/widgets/order/order_status_style.dart';

class OrderDetailTimeline extends StatelessWidget {
  const OrderDetailTimeline({
    super.key,
    required this.current,
    required this.t,
    required this.cs,
    this.isDesktop = false,
  });

  final OrderStatus current;
  final String Function(String) t;
  final ColorScheme cs;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _dot(OrderStatus.served),
            Expanded(child: _line(OrderStatus.served)),
            _dot(OrderStatus.preparing),
            Expanded(child: _line(OrderStatus.preparing)),
            _dot(OrderStatus.pending),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _label('timeline_served', OrderStatus.served),
            _label('timeline_preparing', OrderStatus.preparing),
            _label('timeline_pending', OrderStatus.pending),
          ],
        ),
      ],
    );
  }

  Widget _line(OrderStatus s) {
    final reached = s.index <= current.index;
    return Container(
      height: isDesktop ? 3 : 2,
      color: reached ? OrderStatusStyle.color(s) : cs.outlineVariant,
    );
  }

  Widget _label(String key, OrderStatus s) {
    final bool active = s == OrderStatus.served
        ? current == OrderStatus.served
        : s == OrderStatus.preparing
        ? current.index >= OrderStatus.preparing.index
        : current == OrderStatus.pending;
    return Flexible(
      child: Text(
        t(key),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isDesktop ? 12 : 9,
          color: active ? OrderStatusStyle.color(s) : cs.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _dot(OrderStatus s) {
    final isReached = s.index <= current.index;
    final c = OrderStatusStyle.color(s);
    final size = isDesktop ? 18.0 : 14.0;
    final iconS = isDesktop ? 10.0 : 8.0;
    return Container(
      width: isReached ? size : size * 0.7,
      height: isReached ? size : size * 0.7,
      decoration: BoxDecoration(
        color: isReached ? c : cs.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isReached ? c : cs.outlineVariant,
          width: isDesktop ? 3.0 : 2.0,
        ),
      ),
      child: isReached
          ? Icon(Icons.check, size: iconS, color: cs.onPrimary)
          : null,
    );
  }
}
