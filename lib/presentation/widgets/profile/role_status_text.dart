import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class RoleStatusTexts extends StatelessWidget {
  const RoleStatusTexts({
    super.key,
    required this.title,
    required this.subtitle,
    required this.success,
    required this.done,
    required this.pulse,
  });

  final String title;
  final String subtitle;
  final bool success;
  final bool done;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final subtitleColor = done
        ? (success ? AppColors.success : AppColors.error)
        : cs.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: R.fontXl(context),
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Opacity(
              key: ValueKey(done),
              opacity: done ? 1 : pulse.value,
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: R.fontMd(context),
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
