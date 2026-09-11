import 'package:flutter/material.dart';

/// An item list wrapper that plays an entrance animation the first time an
/// item appears (fade + slide-up + scale) and a graceful exit when an item is
/// removed from [ids] (fade + slide-down + scale + vertical collapse).
///
/// Works on both a [ListView] (phone) and a [Wrap] grid (tablet/desktop).
/// Exiting items keep their original slot while shrinking, so remaining items
/// reflow smoothly.
class AnimatedItemList extends StatefulWidget {
  final List<Object> ids;
  final Widget Function(BuildContext context, Object id) itemBuilder;
  final bool isGrid;
  final double? itemWidth;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;

  const AnimatedItemList({
    super.key,
    required this.ids,
    required this.itemBuilder,
    this.isGrid = false,
    this.itemWidth,
    this.spacing = 12,
    this.padding = EdgeInsets.zero,
    this.physics,
  });

  @override
  State<AnimatedItemList> createState() => _AnimatedItemListState();
}

class _Entry {
  _Entry(this.id, this.controller);

  final Object id;
  final AnimationController controller;
  bool exiting = false;
  int removedIndex = 0;
}

class _AnimatedItemListState extends State<AnimatedItemList>
    with TickerProviderStateMixin {
  final _entries = <Object, _Entry>{};

  @override
  void initState() {
    super.initState();
    for (final id in widget.ids) {
      _entries[id] = _newEntry(id);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedItemList old) {
    super.didUpdateWidget(old);
    final prev = old.ids.toSet();
    final next = widget.ids.toSet();
    for (final id in prev.difference(next)) {
      final e = _entries[id];
      if (e == null || e.exiting) continue;
      e
        ..exiting = true
        ..removedIndex = old.ids.indexOf(id)
        ..controller.reverse();
    }
    for (final id in next.difference(prev)) {
      _entries[id] = _newEntry(id);
    }
  }

  _Entry _newEntry(Object id) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: 0,
    );
    final entry = _Entry(id, controller);
    controller.forward();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && entry.exiting) {
        if (mounted) {
          setState(() => _entries.remove(id));
        }
        controller.dispose();
      }
    });
    return entry;
  }

  @override
  void dispose() {
    for (final e in _entries.values) {
      e.controller.dispose();
    }
    _entries.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slots = <({int order, _Entry entry, Widget child})>[];
    var i = 0;
    for (final id in widget.ids) {
      final e = _entries[id];
      if (e == null) {
        i++;
        continue;
      }
      slots.add(
        (
          order: i,
          entry: e,
          child: KeyedSubtree(
            key: ValueKey(id),
            child: widget.itemBuilder(context, id),
          ),
        ),
      );
      i++;
    }
    for (final e in _entries.values) {
      if (!e.exiting) continue;
      slots.add(
        (
          order: e.removedIndex,
          entry: e,
          child: KeyedSubtree(
            key: ValueKey(e.id),
            child: widget.itemBuilder(context, e.id),
          ),
        ),
      );
    }
    slots.sort((a, b) => a.order.compareTo(b.order));

    final children = [
      for (final slot in slots)
        _AnimatedSlot(entry: slot.entry, child: slot.child),
    ];

    if (widget.isGrid) {
      return SingleChildScrollView(
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        child: Wrap(
          spacing: widget.spacing,
          runSpacing: widget.spacing,
          children: [
            for (final child in children)
              SizedBox(width: widget.itemWidth, child: child),
          ],
        ),
      );
    }
    return ListView(
      physics: widget.physics,
      padding: widget.padding,
      children: children,
    );
  }
}

class _AnimatedSlot extends StatelessWidget {
  final _Entry entry;
  final Widget child;

  const _AnimatedSlot({required this.entry, required this.child});

  @override
  Widget build(BuildContext context) {
    final e = entry;
    return AnimatedBuilder(
      animation: e.controller,
      child: child,
      builder: (context, child) {
        final v = Curves.easeOutCubic.transform(e.controller.value);
        return SizeTransition(
          sizeFactor: e.exiting
              ? e.controller
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