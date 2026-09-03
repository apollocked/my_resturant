import 'package:flutter/material.dart';
import 'package:my_resturant/presentation/pages/layout/nav_item.dart';
import 'package:my_resturant/shared/cart_badge.dart';

class NavDestination {
  const NavDestination({required this.item, required this.cartCount});

  final NavItem item;
  final int cartCount;

  NavigationRailDestination destination({
    required String label,
    double? iconSize,
    double? labelSize,
  }) {
    final showBadge = item.index == 0 && cartCount > 0;
    return NavigationRailDestination(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(item.outline, size: iconSize),
          if (showBadge)
            Positioned(
              top: -6,
              right: -6,
              child: CartBadge(count: cartCount),
            ),
        ],
      ),
      selectedIcon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(item.filled, size: iconSize),
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
