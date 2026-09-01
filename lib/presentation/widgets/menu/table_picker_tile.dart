import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class TablePickerTile extends StatelessWidget {
  const TablePickerTile({
    super.key,
    required this.n,
    required this.locked,
    required this.cs,
    required this.isDesktop,
    required this.onTap,
    required this.t,
  });

  final int n;
  final bool locked;
  final ColorScheme cs;
  final bool isDesktop;
  final VoidCallback onTap;
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    final radius = isDesktop ? 18.0 : 14.0;
    return Material(
      color: locked ? cs.outline : AppColors.primary,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: locked ? null : onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (locked) ...[
              Icon(Icons.lock, color: cs.surface, size: isDesktop ? 28 : 20),
              const SizedBox(height: 2),
              Text(
                t('table_n').replaceAll('{n}', '$n'),
                style: TextStyle(
                  color: cs.surface,
                  fontSize: isDesktop ? 16 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Text(
                '$n',
                style: TextStyle(
                  color: cs.surface,
                  fontSize: isDesktop ? 32 : 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                t('table'),
                style: TextStyle(
                  color: cs.surface.withValues(alpha: 0.7),
                  fontSize: isDesktop ? 14 : 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
