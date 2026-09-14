import 'package:flutter/material.dart';
import 'package:my_resturant/domain/entities/role.dart';

class NavItem {
  final IconData outline, filled;
  final String labelKey;
  final int index;
  const NavItem(this.outline, this.filled, this.labelKey, this.index);

  static List<NavItem> forRole(Role role) {
    final items = <NavItem>[];
    void add(IconData o, IconData f, String key, int index) =>
        items.add(NavItem(o, f, key, index));

    switch (role) {
      case Role.kitchen:
        add(Icons.receipt_long_outlined, Icons.receipt_long, 'kitchen', 2);
        add(Icons.person_outline, Icons.person, 'profile', 4);
      case Role.admin:
        add(Icons.shopping_bag_outlined, Icons.shopping_bag, 'cart', 0);
        add(Icons.menu_book_outlined, Icons.menu_book, 'menu', 1);
        add(Icons.receipt_long_outlined, Icons.receipt_long, 'kitchen', 2);
        add(Icons.history_outlined, Icons.history, 'history', 3);
        add(Icons.person_outline, Icons.person, 'profile', 4);
      case Role.waiter:
        add(Icons.shopping_bag_outlined, Icons.shopping_bag, 'cart', 0);
        add(Icons.menu_book_outlined, Icons.menu_book, 'menu', 1);
        add(Icons.receipt_long_outlined, Icons.receipt_long, 'orders', 2);
        add(Icons.person_outline, Icons.person, 'profile', 4);
    }
    return items;
  }
}
