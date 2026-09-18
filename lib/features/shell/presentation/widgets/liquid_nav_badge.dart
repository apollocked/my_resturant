import 'package:flutter/material.dart';

/// A compact solid capsule that carries the cart/order count on a nav tab.
class LiquidNavBadge extends StatelessWidget {
  final int count;
  final Color accentColor;
  final Color borderColor;

  const LiquidNavBadge({
    super.key,
    required this.count,
    required this.accentColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: Container(
        key: ValueKey(count),
        alignment: Alignment.center,
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: borderColor, width: 1.6),
        ),
        child: Text(
          '$count',
          style: TextStyle(
            color: cs.onPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}