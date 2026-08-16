import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class ElapsedTimeChip extends StatelessWidget {
  const ElapsedTimeChip({
    super.key,
    required this.createdAt,
    required this.locale,
  });

  final DateTime createdAt;
  final Locale locale;

  String _elapsed() {
    final min = DateTime.now().difference(createdAt).inMinutes;
    if (min < 1) return Tr.get('time_under_1m', locale);
    if (min < 60) return Tr.get('time_m', locale).replaceAll('{m}', '$min');
    return Tr.get('time_hm', locale)
        .replaceAll('{h}', '${min ~/ 60}')
        .replaceAll('{m}', '${min % 60}');
  }

  Color _urgencyColor(int minutes) {
    if (minutes < 5) return AppColors.success;
    if (minutes < 15) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final min = DateTime.now().difference(createdAt).inMinutes;
    final urgency = _urgencyColor(min);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: urgency.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 12, color: urgency),
          const SizedBox(width: 3),
          Text(
            _elapsed(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: R.fontSm(context),
              color: urgency,
            ),
          ),
        ],
      ),
    );
  }
}
