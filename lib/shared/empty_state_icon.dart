import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

/// The animated centerpiece of an [EmptyState]: a soft glowing halo, two
/// blurred depth orbs and a floating gradient icon squircle that bobs on the
/// [float] animation.
class EmptyStateIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool compact;
  final Animation<double> float;

  const EmptyStateIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.compact,
    required this.float,
  });

  @override
  Widget build(BuildContext context) {
    final tile = compact ? 84.0 : R.avatarSize(context);
    final glow = tile * (compact ? 2.2 : 2.6);
    final iconSize = tile * (compact ? 0.42 : 0.45);

    return SizedBox(
      width: glow,
      height: glow,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Halo / ambient glow behind the icon tile.
          Container(
            width: glow,
            height: glow,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: compact ? 0.16 : 0.14),
                  color.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const [0, 0.55, 1],
              ),
            ),
          ),
          // Two blurred depth orbs.
          Positioned(
            top: glow * 0.12,
            left: glow * 0.18,
            child: _Orb(size: compact ? 10 : 14, color: color),
          ),
          Positioned(
            bottom: glow * 0.12,
            right: glow * 0.14,
            child: _Orb(size: compact ? 7 : 10, color: color),
          ),
          // Floating icon tile.
          AnimatedBuilder(
            animation: float,
            builder: (context, _) {
              final dy =
                  math.sin(float.value * 2 * math.pi) * (compact ? 3 : 4);
              return Transform.translate(
                offset: Offset(0, dy),
                child: Container(
                  width: tile,
                  height: tile,
                  alignment: Alignment.center,
                  // Rounded-rect squircle (consistent with the dock).
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(tile * 0.32),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.32),
                        color.withValues(alpha: 0.12),
                      ],
                    ),
                    border: Border.all(
                      color: color.withValues(alpha: 0.30),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.18),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: iconSize, color: color),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A soft blurred dot used to give the empty state extra depth.
class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.22),
      ),
    );
  }
}