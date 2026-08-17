import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class LiquidNavShine extends StatelessWidget {
  const LiquidNavShine({super.key, required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Positioned(
      top: -40,
      left: -40,
      child: IgnorePointer(
        child: Container(
          width: 200,
          height: 120,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                cs.onPrimary.withValues(alpha: dark ? 0.08 : 0.12),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.circle),
          ),
        ),
      ),
    );
  }
}
