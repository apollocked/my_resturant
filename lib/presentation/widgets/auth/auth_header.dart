import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.isSignUp, required this.t});

  final bool isSignUp;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: R.avatarSize(context),
          height: R.avatarSize(context),
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/icons/my Restaurant.png',
              width: R.avatarSize(context),
              height: R.avatarSize(context),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: R.gridSpacing(context)),
        Text(
          isSignUp ? t('create_account_title') : t('restaurant_name'),
          style: TextStyle(
            fontSize: R.fontXl(context),
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isSignUp ? t('create_account_subtitle') : t('account_login_subtitle'),
          style: TextStyle(
            fontSize: R.fontSm(context),
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
