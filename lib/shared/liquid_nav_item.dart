import 'package:flutter/material.dart';
import 'package:my_resturant/shared/nav_rive_icon.dart';

class LiquidNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final NavRiveSpec? rive;
  const LiquidNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.rive,
  });
}
