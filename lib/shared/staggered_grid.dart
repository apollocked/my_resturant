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

/// Wraps a [ListView.builder] with the same stagger behaviour.
class StaggeredList extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) builder;
  final Duration staggerDelay;
  final Duration itemDuration;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;

  const StaggeredList({
    super.key,
    required this.itemCount,
    required this.builder,
    this.staggerDelay = const Duration(milliseconds: 45),
    this.itemDuration = const Duration(milliseconds: 350),
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<StaggeredList>
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
  void didUpdateWidget(covariant StaggeredList old) {
    super.didUpdateWidget(old);
    if (old.itemCount != widget.itemCount) {
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
    return ListView.builder(
      itemCount: widget.itemCount,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: widget.padding,
      scrollDirection: widget.scrollDirection,
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
