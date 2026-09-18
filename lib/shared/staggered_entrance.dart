import 'package:flutter/material.dart';

/// Standalone item-level stagger wrapper for use outside of [StaggeredGrid]
/// (e.g. in [ListView], [Wrap], or any irregular layout).
///
/// Each instance starts its own 300 ms fade + slide-up + scale animation on
/// first build. When items are laid out sequentially by the framework, they
/// mount in order, producing a natural cascade without requiring an external
/// controller.
///
/// ```dart
/// for (final item in items)
///   StaggeredEntrance(child: OrderCard(item))
/// ```
class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const StaggeredEntrance({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curve,
      child: ScaleTransition(
        scale: Tween(begin: 0.96, end: 1.0).animate(curve),
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curve),
          child: widget.child,
        ),
      ),
    );
  }
}