import 'package:flutter/material.dart';

import 'package:my_resturant/shared/animated_item_entry.dart';

/// One row of an [AnimatedItemList]: a fade + slide-up + scale entrance on
/// arrival and a vertical-collapse exit while the row is being removed.
class AnimatedItemSlot extends StatelessWidget {
  final AnimEntry entry;
  final Widget child;

  const AnimatedItemSlot({super.key, required this.entry, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entry.controller,
      child: child,
      builder: (context, child) {
        final v = Curves.easeOutCubic.transform(entry.controller.value);
        return SizeTransition(
          sizeFactor: entry.exiting
              ? entry.controller
              : const AlwaysStoppedAnimation<double>(1),
          child: Opacity(
            opacity: v.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - v)),
              child: Transform.scale(
                scale: 0.96 + 0.04 * v,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}