import 'package:flutter/material.dart';

/// One staggered cell of a [StaggeredGrid]: an entrance that slides up, fades
/// in and scales on the interval reserved for [index] on the shared
/// [controller].
class StaggeredGridItem extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Widget child;

  const StaggeredGridItem({
    super.key,
    required this.controller,
    required this.index,
    required this.staggerDelay,
    required this.itemDuration,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (staggerDelay.inMilliseconds * index) /
        (controller.duration?.inMilliseconds ?? 1);
    final end = (staggerDelay.inMilliseconds * index +
            itemDuration.inMilliseconds) /
        (controller.duration?.inMilliseconds ?? 1);
    final interval = Interval(
      start.clamp(0.0, 1.0),
      end.clamp(0.0, 1.0),
      curve: Curves.easeOutCubic,
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = interval.transform(controller.value.clamp(0.0, 1.0));
        return Transform.translate(
          offset: Offset(0, 24 * (1 - t)),
          child: Opacity(
            opacity: t,
            child: Transform.scale(
              scale: 0.95 + 0.05 * t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}