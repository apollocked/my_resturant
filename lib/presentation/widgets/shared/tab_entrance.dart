import 'package:flutter/material.dart';

class TabEntrance extends StatelessWidget {
  final int index;
  final Widget child;
  const TabEntrance({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(index),
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: 1 - 0.35 * value,
        child: Transform.translate(
          offset: Offset(0, 12 * value),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
