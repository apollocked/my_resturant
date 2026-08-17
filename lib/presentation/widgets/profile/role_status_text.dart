import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class RoleStatusTexts extends StatelessWidget {
  const RoleStatusTexts({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.pulse,
  });

  final String title;
  final String subtitle;
  final bool done;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: R.fontXl(context),
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Opacity(
            key: ValueKey(done),
            opacity: done ? 1 : pulse.value,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.fontSm(context),
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
