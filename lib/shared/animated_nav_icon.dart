import 'package:flutter/material.dart';

/// A Material-icon nav icon that pops whenever [active] changes.
///
/// The entire pop (scale, lift, tilt and color) is driven by a single
/// [TweenAnimationBuilder] value so the animation is perfectly synchronized
/// and identical for every tab. There is deliberately no [AnimatedSwitcher]
/// here: its child-crossfade only animates when the outline/filled glyphs
/// differ perceptibly, so tabs with near-identical glyphs looked frozen.
class AnimatedNavIcon extends StatelessWidget {
  final bool active;
  final IconData icon;
  final IconData activeIcon;
  final Color color;
  final Color inactiveColor;
  final double size;

  const AnimatedNavIcon({
    super.key,
    required this.active,
    required this.icon,
    required this.activeIcon,
    required this.color,
    required this.inactiveColor,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: active ? 1 : 0),
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutBack,
      builder: (context, v, _) {
        final t = v.clamp(0.0, 1.0);
        final col = Color.lerp(inactiveColor, color, t) ?? color;
        return Opacity(
          opacity: active ? 1.0 : 0.65,
          child: Transform.translate(
            offset: Offset(0, -5 * t),
            child: Transform.rotate(
              angle: 0.14 * (1 - t),
              child: Transform.scale(
                scale: 0.7 + 0.3 * v,
                child: Icon(
                  v > 0.5 ? activeIcon : icon,
                  size: size,
                  color: col,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}