import 'package:flutter/material.dart';

import 'package:my_resturant/features/shell/presentation/widgets/liquid_nav_item.dart';
import 'package:my_resturant/features/shell/presentation/widgets/liquid_nav_tab.dart';

/// The full-width row of tappable tabs that sits above the animated chip.
class LiquidGlassTabRow extends StatelessWidget {
  final List<LiquidNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color sel;
  final Color unsel;
  final Color accentColor;
  final bool dark;
  final int? badgeIndex;
  final int? badgeCount;

  const LiquidGlassTabRow({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    required this.sel,
    required this.unsel,
    required this.accentColor,
    required this.dark,
    this.badgeIndex,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RepaintBoundary(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final item = items[i];
            return LiquidNavTab(
              item: item,
              index: i,
              active: selectedIndex == i,
              sel: sel,
              unsel: unsel,
              accentColor: accentColor,
              dark: dark,
              showBadge: badgeIndex == i && (badgeCount ?? 0) > 0,
              badgeCount: badgeCount,
              onTap: () => onTap(i),
            );
          }),
        ),
      ),
    );
  }
}