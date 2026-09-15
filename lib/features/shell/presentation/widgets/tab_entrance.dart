import 'package:flutter/material.dart';

/// Animates the screen content when the bottom-nav tab changes.
/// The incoming screen slides in horizontally from the side of the newly
/// selected tab, fading in while the outgoing content gently fades out.
class TabEntrance extends StatefulWidget {
  final int index;
  final Widget child;
  const TabEntrance({super.key, required this.index, required this.child});

  @override
  State<TabEntrance> createState() => _TabEntranceState();
}

class _TabEntranceState extends State<TabEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctl;
  late int _previous;
  int _direction = 1;

  @override
  void initState() {
    super.initState();
    _previous = widget.index;
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant TabEntrance old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _direction = widget.index > _previous ? 1 : -1;
      _previous = widget.index;
      _ctl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_ctl.value);
        final arriving = Transform.translate(
          offset: Offset(_direction * 42 * (1 - t), 0),
          child: Opacity(opacity: t, child: child),
        );
        return Stack(
          children: [Positioned.fill(child: arriving)],
        );
      },
      child: KeyedSubtree(key: ValueKey(widget.index), child: widget.child),
    );
  }
}
