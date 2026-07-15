import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class CategoryChip extends StatelessWidget {
  final String icon, name;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;

  const CategoryChip({super.key, required this.icon, required this.name, required this.isSelected,
    required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screen = R.screenSize(context);
    final isDesktop = screen == ScreenSize.desktop;
    final isTablet = screen == ScreenSize.tablet;
    final paddingH = isDesktop ? 20 : isTablet ? 16 : 14;
    final paddingV = isDesktop ? 14 : isTablet ? 10 : 8;
    final iconSize = isDesktop ? 20.0 : isTablet ? 17.0 : 15.0;
    final textSize = isDesktop ? 14.0 : isTablet ? 13.0 : 12.0;
    final radius = isDesktop ? 28.0 : isTablet ? 24.0 : 20.0;
    final spacing = isDesktop ? 10 : isTablet ? 8 : 6;
    return Padding(
      padding: EdgeInsets.only(left: index == 0 ? (isDesktop ? 24 : 20) : 0, right: index > 0 ? (isDesktop ? 14 : 8) : 0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : cs.surface,
            borderRadius: BorderRadius.circular(radius),
            border: isSelected ? null : Border.all(color: cs.outlineVariant),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : null),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(icon, style: TextStyle(fontSize: iconSize)),
            SizedBox(width: spacing),
            Text(name, style: TextStyle(
                color: isSelected ? cs.onPrimary : cs.onSurface,
                fontWeight: FontWeight.w600, fontSize: textSize)),
          ]),
        ),
      ),
    );
  }
}
