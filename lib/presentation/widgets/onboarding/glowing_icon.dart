import 'package:flutter/material.dart';
import 'package:my_resturant/presentation/pages/onboarding/onb_colors.dart';

class GlowingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final OnbColors ob;
  const GlowingIcon({super.key, required this.icon, required this.color, required this.ob});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110, height: 110,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: ob.isDark ? 0.5 : 0.3), blurRadius: 60, spreadRadius: 20)]),
      child: Container(
        width: 110, height: 110,
        decoration: BoxDecoration(shape: BoxShape.circle, color: ob.iconCircleBg, border: Border.all(color: ob.iconCircleBorder, width: 1.5)),
        child: Icon(icon, size: 52, color: ob.textPrimary),
      ),
    );
  }
}
