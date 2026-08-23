import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/pages/onboarding/onb_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class GlowingSettingIcon extends StatelessWidget {
  final OnbColors ob;
  const GlowingSettingIcon({super.key, required this.ob});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: R.avatarSize(context),
      height: R.avatarSize(context),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ob.iconCircleBg,
        border: Border.all(color: ob.iconCircleBorder, width: 1.5),
      ),
      child: Icon(
        Icons.language_rounded,
        size: R.avatarSize(context) * 0.5,
        color: ob.textPrimary,
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String label;
  final OnbColors ob;
  const SectionLabel({super.key, required this.label, required this.ob});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: TextStyle(
          fontSize: R.fontMd(context),
          fontWeight: FontWeight.w700,
          color: ob.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class LanguageOption extends StatelessWidget {
  final String label, flag;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;
  final OnbColors ob;
  const LanguageOption({
    super.key,
    required this.label,
    required this.flag,
    required this.locale,
    required this.isSelected,
    required this.onTap,
    required this.ob,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: R.cardPadding(context),
          vertical: R.cardPadding(context),
        ),
        decoration: BoxDecoration(
          color: isSelected ? ob.selectedBg : ob.glassBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? ob.selectedBorder : ob.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: R.fontXl(context))),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: R.fontMd(context),
                  fontWeight: FontWeight.w600,
                  color: ob.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: ob.textPrimary, size: 22),
          ],
        ),
      ),
    );
  }
}

class ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final OnbColors ob;
  const ThemeOption({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.ob,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: R.cardPadding(context)),
        decoration: BoxDecoration(
          color: isSelected ? ob.selectedBg : ob.glassBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? ob.selectedBorder : ob.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: ob.textPrimary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: R.fontSm(context),
                fontWeight: FontWeight.w600,
                color: ob.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
