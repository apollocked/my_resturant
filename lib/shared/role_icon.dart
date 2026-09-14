import 'package:flutter/material.dart';
import 'package:my_resturant/features/auth/domain/entities/role.dart';

/// Presentation-side metadata for a [Role]. Kept out of the domain entity so
/// the domain layer stays free of any UI framework dependency.
extension RoleIcon on Role {
  IconData get icon => switch (this) {
    Role.waiter => Icons.room_service_outlined,
    Role.kitchen => Icons.restaurant_outlined,
    Role.admin => Icons.admin_panel_settings_outlined,
  };
}