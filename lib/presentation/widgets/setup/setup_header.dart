import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class SetupHeader extends StatelessWidget {
  const SetupHeader({super.key, required this.t});

  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: R.avatarSize(context),
          height: R.avatarSize(context),
          decoration: BoxDecoration(
            color: AppColors.softSurface(context),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_outline,
            size: R.avatarSize(context) * 0.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          t('setup_title'),
          style: TextStyle(
            fontSize: R.fontXl(context),
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t('setup_subtitle'),
          style: TextStyle(
            fontSize: R.fontSm(context),
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
