import 'package:flutter/material.dart';

/// Wraps a [GridView] or [ListView] builder and staggers each child's entrance
/// with a fade + slide-up + slight scale, driven by an [AnimationController]
/// the parent owns (or by its own internal one-shot controller when used as a
/// standalone widget).
///
/// Usage as a standalone (one-shot stagger on build):
/// ```dart
/// StaggeredGrid(
///   key: ValueKey(category), // re-trigger on category change
///   itemCount: items.length,
///   builder: (ctx, i) => ItemCard(items[i]),
/// )
/// ```
class StaggeredGrid extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) builder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final Duration staggerDelay;
  final Duration itemDuration;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;

  const StaggeredGrid({
    super.key,
    required this.itemCount,
    required this.builder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1,
    this.staggerDelay = const Duration(milliseconds: 40),
    this.itemDuration = const Duration(milliseconds: 350),
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<StaggeredGrid> createState() => _StaggeredGridState();
}

class _StaggeredGridState extends State<StaggeredGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.itemDuration + widget.staggerDelay * widget.itemCount,
    )..forward();
  }

  @override
  void didUpdateWidget(covariant StaggeredGrid old) {
    super.didUpdateWidget(old);
    if (old.itemCount != widget.itemCount ||
        old.itemDuration != widget.itemDuration ||
        old.staggerDelay != widget.staggerDelay) {
      _ctrl
        ..duration = widget.itemDuration +
            widget.staggerDelay * widget.itemCount
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: widget.itemCount,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: widget.padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemBuilder: (ctx, i) => _StaggeredItem(
        controller: _ctrl,
        index: i,
        staggerDelay: widget.staggerDelay,
        itemDuration: widget.itemDuration,
        child: widget.builder(ctx, i),
      ),
    );
  }
}

class _StaggeredItem extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Widget child;

  const _StaggeredItem({
    required this.controller,
    required this.index,
    required this.staggerDelay,
    required this.itemDuration,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start =
        (staggerDelay.inMilliseconds * index) /
        (controller.duration?.inMilliseconds ?? 1);
    final end =
        (staggerDelay.inMilliseconds * index + itemDuration.inMilliseconds) /
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

/// Standalone item-level stagger wrapper for use outside of [StaggeredGrid]
/// (e.g. in [ListView], [Wrap], or any irregular layout).
///
/// Each instance starts its own 300 ms fade + slide-up + scale animation
/// on first build. When items are laid out sequentially by the framework,
/// they mount in order, producing a natural cascade without requiring an
/// external controller.
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
