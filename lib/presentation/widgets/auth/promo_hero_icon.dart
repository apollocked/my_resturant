import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class PromoHeroIcon extends StatelessWidget {
  const PromoHeroIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: R.avatarSize(context),
      height: R.avatarSize(context),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.vpn_key, size: 40, color: AppColors.primary),
    );
  }
}
