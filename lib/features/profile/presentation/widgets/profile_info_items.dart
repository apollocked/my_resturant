import 'package:flutter/material.dart';

import 'package:my_resturant/features/auth/domain/entities/role.dart';

/// One entry in the "What can you do here?" guide shown in the profile page.
class InfoItem {
  final IconData icon;
  final String titleKey;
  final String descKey;
  final List<String> featKeys;
  final Set<Role> visibleFor;

  const InfoItem({
    required this.icon,
    required this.titleKey,
    required this.descKey,
    required this.featKeys,
    required this.visibleFor,
  });
}

const List<InfoItem> kProfileInfoItems = [
  InfoItem(
    icon: Icons.menu_book_outlined,
    titleKey: 'info_menu_title',
    descKey: 'info_menu_desc',
    featKeys: ['info_menu_feat_1', 'info_menu_feat_2', 'info_menu_feat_3'],
    visibleFor: {Role.waiter, Role.admin},
  ),
  InfoItem(
    icon: Icons.shopping_bag_outlined,
    titleKey: 'info_cart_title',
    descKey: 'info_cart_desc',
    featKeys: ['info_cart_feat_1', 'info_cart_feat_2', 'info_cart_feat_3'],
    visibleFor: {Role.waiter, Role.admin},
  ),
  InfoItem(
    icon: Icons.receipt_long_outlined,
    titleKey: 'info_kitchen_title',
    descKey: 'info_kitchen_desc',
    featKeys: ['info_kitchen_feat_1', 'info_kitchen_feat_2', 'info_kitchen_feat_3'],
    visibleFor: {Role.waiter, Role.kitchen, Role.admin},
  ),
  InfoItem(
    icon: Icons.receipt_outlined,
    titleKey: 'info_order_detail_title',
    descKey: 'info_order_detail_desc',
    featKeys: ['info_order_detail_feat_1', 'info_order_detail_feat_2', 'info_order_detail_feat_3'],
    visibleFor: {Role.waiter, Role.kitchen, Role.admin},
  ),
  InfoItem(
    icon: Icons.history,
    titleKey: 'info_history_title',
    descKey: 'info_history_desc',
    featKeys: ['info_history_feat_1', 'info_history_feat_2', 'info_history_feat_3'],
    visibleFor: {Role.admin},
  ),
  InfoItem(
    icon: Icons.bar_chart,
    titleKey: 'info_report_title',
    descKey: 'info_report_desc',
    featKeys: ['info_report_feat_1', 'info_report_feat_2', 'info_report_feat_3'],
    visibleFor: {Role.admin},
  ),
  InfoItem(
    icon: Icons.table_restaurant_outlined,
    titleKey: 'info_table_management_title',
    descKey: 'info_table_management_desc',
    featKeys: ['info_table_management_feat_1', 'info_table_management_feat_2'],
    visibleFor: {Role.admin},
  ),
  InfoItem(
    icon: Icons.restaurant_menu,
    titleKey: 'info_food_management_title',
    descKey: 'info_food_management_desc',
    featKeys: ['info_food_management_feat_1', 'info_food_management_feat_2', 'info_food_management_feat_3'],
    visibleFor: {Role.admin},
  ),
  InfoItem(
    icon: Icons.category_outlined,
    titleKey: 'info_category_management_title',
    descKey: 'info_category_management_desc',
    featKeys: ['info_category_management_feat_1', 'info_category_management_feat_2'],
    visibleFor: {Role.admin},
  ),
  InfoItem(
    icon: Icons.toggle_on_outlined,
    titleKey: 'info_availability_title',
    descKey: 'info_availability_desc',
    featKeys: ['info_availability_feat_1', 'info_availability_feat_2'],
    visibleFor: {Role.admin},
  ),
  InfoItem(
    icon: Icons.lock_outline,
    titleKey: 'info_change_pins_title',
    descKey: 'info_change_pins_desc',
    featKeys: ['info_change_pins_feat_1', 'info_change_pins_feat_2'],
    visibleFor: {Role.admin},
  ),
  InfoItem(
    icon: Icons.print_outlined,
    titleKey: 'info_printer_title',
    descKey: 'info_printer_desc',
    featKeys: ['info_printer_feat_1', 'info_printer_feat_2', 'info_printer_feat_3'],
    visibleFor: {Role.waiter, Role.kitchen, Role.admin},
  ),
  InfoItem(
    icon: Icons.bluetooth_searching,
    titleKey: 'info_printer_discovery_title',
    descKey: 'info_printer_discovery_desc',
    featKeys: ['info_printer_discovery_feat_1', 'info_printer_discovery_feat_2'],
    visibleFor: {Role.waiter, Role.kitchen, Role.admin},
  ),
  InfoItem(
    icon: Icons.person_outline,
    titleKey: 'info_profile_title',
    descKey: 'info_profile_desc',
    featKeys: ['info_profile_feat_1', 'info_profile_feat_2', 'info_profile_feat_3'],
    visibleFor: {Role.waiter, Role.kitchen, Role.admin},
  ),
];