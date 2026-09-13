import 'package:flutter/material.dart';

/// A springy, gravity-weighted nav icon.
///
/// Activation drives a single [TweenAnimationBuilder] value so scale, lift,
/// tilt, color and the outline→filled glyph cross-fade are all perfectly
/// synchronized. The two glyphs cross-fade with opacity (rather than a hard
/// swap) so even near-identical outline/filled pairs always animate smoothly.
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
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (context, v, _) {
        final t = v.clamp(0.0, 1.0);
        final col = Color.lerp(inactiveColor, color, t) ?? color;
        return Opacity(
          opacity: 0.62 + 0.38 * t,
          child: Transform.translate(
            offset: Offset(0, -6 * t),
            child: Transform.rotate(
              angle: 0.16 * (1 - t),
              child: Transform.scale(
                scale: 0.62 + 0.38 * v,
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
              ),
            ),
          ),
        );
      },
    );
  }
}