import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/features/onboarding/presentation/pages/onb_colors.dart';

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