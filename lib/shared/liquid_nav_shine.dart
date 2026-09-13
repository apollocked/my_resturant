import 'package:flutter/material.dart';

/// The 2026 aurora sheen: a soft diagonal light-sheet over the dock plus a
/// faint color bloom on the motion side. Pure decoration, ignores pointers.
class LiquidNavShine extends StatelessWidget {
  const LiquidNavShine({super.key, required this.dark, this.color});

  final bool dark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tint = color ?? cs.primary;
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -64,
            left: -34,
            width: 240,
            height: 126,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: dark ? 0.13 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -40,
            bottom: -70,
            width: 210,
            height: 128,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    tint.withValues(alpha: dark ? 0.16 : 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}