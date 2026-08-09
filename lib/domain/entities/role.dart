import 'package:flutter/material.dart';

enum Role { waiter, kitchen, admin }

extension RoleExtension on Role {
  String get key => name;
  IconData get icon => switch (this) {
    Role.waiter => Icons.room_service_outlined,
    Role.kitchen => Icons.restaurant_outlined,
    Role.admin => Icons.admin_panel_settings_outlined,
  };
  static Role fromKey(String key) => Role.values.firstWhere((r) => r.name == key, orElse: () => Role.waiter);
}
