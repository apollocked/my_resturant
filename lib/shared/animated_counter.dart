import 'package:flutter/material.dart';

/// Smoothly animates between two numeric values by interpolating the displayed
/// text. When [value] changes the text rolls up/down with a spring-like ease.
///
/// ```dart
/// AnimatedCounter(value: cartTotal, suffix: ' IQ')
/// ```
class AnimatedCounter extends StatefulWidget {
  final num value;
  final Duration duration;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final int decimals;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 350),
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> {
  num _previous = 0;

  @override
  void initState() {
    super.initState();
    _previous = widget.value;
  }

  @override
  void didUpdateWidget(covariant AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _previous = old.value;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.value),
      tween: Tween(begin: _previous.toDouble(), end: widget.value.toDouble()),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        final text = widget.decimals > 0
            ? v.toStringAsFixed(widget.decimals)
            : v.toInt().toString();
        return Text(
          '${widget.prefix}$text${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}

/// AnimatedCounter variant that slides digits vertically like an odometer.
///
/// ```dart
/// SlideCounter(value: cartCount)
/// ```
class SlideCounter extends StatelessWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;

  const SlideCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 300),
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.4),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      ),
      child: Text(
        '$value',
        key: ValueKey(value),
        style: style,
      ),
    );
  }
}
