import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class RoleLoginHeader extends StatelessWidget {
  const RoleLoginHeader({super.key, required this.t});

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
          child: const Icon(
            Icons.admin_panel_settings_outlined,
            size: 36,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          t('role_login_title'),
          style: TextStyle(
            fontSize: R.fontXl(context),
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          t('role_login_subtitle'),
          style: TextStyle(
            fontSize: R.fontSm(context),
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
