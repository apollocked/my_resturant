import 'package:flutter/material.dart';
import 'package:my_resturant/features/setup/presentation/widgets/setup_passcode_field.dart';

/// The three waiter/kitchen/admin passcode inputs of the setup screen.
class SetupPasscodeFields extends StatelessWidget {
  final TextEditingController waiterCtl;
  final TextEditingController kitchenCtl;
  final TextEditingController adminCtl;
  final bool obscureWaiter;
  final bool obscureKitchen;
  final bool obscureAdmin;
  final VoidCallback onToggleWaiter;
  final VoidCallback onToggleKitchen;
  final VoidCallback onToggleAdmin;
  final String Function(String) t;

  const SetupPasscodeFields({
    super.key,
    required this.waiterCtl,
    required this.kitchenCtl,
    required this.adminCtl,
    required this.obscureWaiter,
    required this.obscureKitchen,
    required this.obscureAdmin,
    required this.onToggleWaiter,
    required this.onToggleKitchen,
    required this.onToggleAdmin,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SetupPasscodeField(
          controller: waiterCtl,
          label: t('waiter'),
          icon: Icons.room_service_outlined,
          obscure: obscureWaiter,
          onToggleObscure: onToggleWaiter,
          t: t,
        ),
        const SizedBox(height: 14),
        SetupPasscodeField(
          controller: kitchenCtl,
          label: t('kitchen'),
          icon: Icons.restaurant_outlined,
          obscure: obscureKitchen,
          onToggleObscure: onToggleKitchen,
          t: t,
        ),
        const SizedBox(height: 14),
        SetupPasscodeField(
          controller: adminCtl,
          label: t('admin'),
          icon: Icons.admin_panel_settings_outlined,
          obscure: obscureAdmin,
          onToggleObscure: onToggleAdmin,
          t: t,
        ),
      ],
    );
  }
}