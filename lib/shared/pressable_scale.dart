import 'package:flutter/material.dart';

/// Wraps any widget (button, tile, card) with a physical press-down effect:
/// the child scales down slightly while pressed and springs back on release,
/// mimicking a real tactile button.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;
  final Curve curve;
  final Duration springBackDuration;
  final Curve springBackCurve;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.94,
    this.duration = const Duration(milliseconds: 70),
    this.curve = Curves.easeOut,
    this.springBackDuration = const Duration(milliseconds: 180),
    this.springBackCurve = Curves.easeOutBack,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void didUpdateWidget(covariant PressableScale old) {
    super.didUpdateWidget(old);
    if (old.scaleDown != widget.scaleDown && _ctrl.value > 0) {
      _ctrl.animateBack(
        0,
        duration: widget.duration,
        curve: widget.curve,
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.animateTo(
    1,
    duration: widget.duration,
    curve: widget.curve,
  );
  void _onTapUp(TapUpDetails _) => _ctrl.animateBack(
    0,
    duration: widget.springBackDuration,
    curve: widget.springBackCurve,
  );
  void _onTapCancel() => _ctrl.animateBack(
    0,
    duration: widget.duration,
    curve: widget.curve,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final scale = 1.0 + (widget.scaleDown - 1.0) * _ctrl.value;
          return Transform.scale(scale: scale, child: child);
        },
        child: widget.child,
      ),
    );
  }
}
