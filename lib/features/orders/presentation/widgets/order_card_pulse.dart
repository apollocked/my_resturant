import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:my_resturant/features/orders/domain/entities/order_model.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_status_style.dart';

/// Soft status-change pulse: when an order's status changes, the card gently
/// expands and its border glows in the new status color, then settles.
class OrderCardPulse extends StatefulWidget {
  final OrderStatus status;
  final bool isDesktop;
  final Widget child;

  const OrderCardPulse({
    super.key,
    required this.status,
    required this.isDesktop,
    required this.child,
  });

  @override
  State<OrderCardPulse> createState() => _OrderCardPulseState();
}

class _OrderCardPulseState extends State<OrderCardPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  OrderStatus? _prevStatus;

  @override
  void didUpdateWidget(covariant OrderCardPulse old) {
    super.didUpdateWidget(old);
    if (_prevStatus != widget.status) {
      _prevStatus = widget.status;
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
    final statusColor = OrderStatusStyle.color(widget.status);
    final radius = widget.isDesktop ? 18.0 : 16.0;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = _pulse.value;
        final scale = 1 + 0.014 * math.sin(math.pi * t);
        final glow = (1 - t) * 0.22;
        return Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: statusColor.withValues(alpha: glow),
                width: 1.6,
              ),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}