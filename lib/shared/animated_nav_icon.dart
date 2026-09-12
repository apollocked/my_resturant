import 'package:flutter/material.dart';

/// A Material-icon nav icon that pops, lifts, and cross-fades between
/// [icon] (idle) and [activeIcon] (selected) whenever [active] changes.
///
/// The animation is driven by [TweenAnimationBuilder]: activating a tab plays
/// a springy overshoot pop (easeOutBack), while deactivating settles back.
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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 170),
        switchInCurve: Curves.easeOutBack,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: anim, child: child),
        ),
        child: Icon(
          active ? activeIcon : icon,
          key: ValueKey(active),
          size: size,
          color: active ? color : inactiveColor,
        ),
      ),
      builder: (context, value, child) => Opacity(
        opacity: active ? 1 : 0.6,
        child: Transform.translate(
          offset: Offset(0, -value * size * 0.18),
          child: Transform.scale(scale: 0.72 + 0.28 * value, child: child),
        ),
      ),
    );
  }
}