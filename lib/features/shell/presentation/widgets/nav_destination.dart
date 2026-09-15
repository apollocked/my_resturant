import 'package:flutter/material.dart';
import 'package:my_resturant/features/shell/presentation/widgets/nav_item.dart';
import 'package:my_resturant/features/shell/presentation/widgets/animated_nav_icon.dart';
import 'package:my_resturant/features/shell/presentation/widgets/cart_badge.dart';

class NavDestination {
  const NavDestination({required this.item, required this.cartCount});

  final NavItem item;
  final int cartCount;

  NavigationRailDestination destination({
    required String label,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
    double? iconSize,
    double? labelSize,
  }) {
    final showBadge = item.index == 0 && cartCount > 0;
    return NavigationRailDestination(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedNavIcon(
            active: isSelected,
            icon: item.outline,
            activeIcon: item.filled,
            color: selectedColor,
            inactiveColor: unselectedColor,
            size: iconSize ?? 24,
          ),
          if (showBadge)
            Positioned(
              top: -6,
              right: -6,
              child: CartBadge(count: cartCount),
            ),
        ],
      ),
      label: Text(label, style: TextStyle(fontSize: labelSize)),
    );
  }
}