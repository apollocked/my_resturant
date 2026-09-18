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
    this.needsCleaning = false,
    this.requested = false,
    this.onRequestCleaning,
  });

  final int n;
  final bool locked;
  final bool needsCleaning;
  final bool requested;
  final ColorScheme cs;
  final bool isDesktop;
  final VoidCallback onTap;
  final VoidCallback? onRequestCleaning;
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    final radius = isDesktop ? 18.0 : 14.0;
    final Color fill;
    final Color fg;
    final VoidCallback? handleTap;
    final IconData icon;
    final bool showLabel;

    if (needsCleaning) {
      // Served tables waiting for the kitchen: tappable so the waiter can
      // request cleaning. Amber once requested so kitchen staff see the flag,
      // and tapping again re-notifies as a nudge.
      final accent = AppColors.warning;
      fill = requested ? accent : accent.withValues(alpha: 0.16);
      fg = requested ? cs.onPrimary : accent;
      icon = requested ? Icons.check_circle : Icons.cleaning_services;
      showLabel = true;
      handleTap = onRequestCleaning;
    } else if (locked) {
      // In-service tables (occupied): not actionable while the order runs.
      fill = cs.outline;
      fg = cs.surface;
      icon = Icons.lock;
      showLabel = true;
      handleTap = null;
    } else {
      fill = AppColors.primary;
      fg = cs.surface;
      icon = Icons.table_restaurant;
      showLabel = false;
      handleTap = onTap;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: handleTap,
        child: Container(
          decoration: needsCleaning && !requested
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.55),
                    width: 1.4,
                  ),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: isDesktop ? 28 : 20),
              const SizedBox(height: 2),
              Text(
                showLabel
                    ? t('table_n').replaceAll('{n}', '$n')
                    : '$n',
                style: TextStyle(
                  color: fg,
                  fontSize: isDesktop ? 16 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!showLabel) ...[
                const SizedBox(height: 2),
                Text(
                  t('table'),
                  style: TextStyle(
                    color: fg.withValues(alpha: 0.7),
                    fontSize: isDesktop ? 14 : 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}