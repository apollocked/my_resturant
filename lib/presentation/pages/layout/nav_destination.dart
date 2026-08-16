import 'package:flutter/material.dart';
import 'package:my_resturant/presentation/pages/layout/nav_item.dart';

class NavDestination {
  const NavDestination({required this.item, required this.cartCount});

  final NavItem item;
  final int cartCount;

  NavigationRailDestination destination({
    required String label,
    double? iconSize,
    double? labelSize,
  }) {
    final badge = item.index == 0 && cartCount > 0;
    final badgeLabel = Text('$cartCount', style: const TextStyle(fontSize: 9));
    return NavigationRailDestination(
      icon: badge
          ? Badge(
              label: badgeLabel,
              child: Icon(item.outline, size: iconSize),
            )
          : Icon(item.outline, size: iconSize),
      selectedIcon: badge
          ? Badge(
              label: badgeLabel,
              child: Icon(item.filled, size: iconSize),
            )
          : Icon(item.filled, size: iconSize),
      label: Text(label, style: TextStyle(fontSize: labelSize)),
    );
  }
}
