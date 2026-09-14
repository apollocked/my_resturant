import 'package:flutter/material.dart';

/// A quiet, tactile nav icon.
///
/// Activation drives a single [TweenAnimationBuilder] value. The scale pops
/// with a springy overshoot ([Curves.easeOutBack]) while the color and the
/// outline→filled glyph cross-fade stay smooth ([Curves.easeOutCubic]) for a
/// clean, liquid-feeling activation.
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
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: active ? 1 : 0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        final t = v.clamp(0.0, 1.0);
        final col = Color.lerp(inactiveColor, color, t) ?? color;
        final pop = Curves.easeOutBack.transform(t);
        return Transform.scale(
          scale: 1 + 0.14 * pop,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: 1 - t,
                  child: Icon(icon, size: size, color: col),
                ),
                Opacity(
                  opacity: t,
                  child: Icon(activeIcon, size: size, color: col),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}