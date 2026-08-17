import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

Future<void> showPasscodesSavedDialog(
  BuildContext context,
  Map<String, String> codes,
) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      scrollable: true,
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 28),
          SizedBox(width: 10),
          Text('Passcodes Saved'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Save these passcodes securely. You will need them to log in.',
          ),
          const SizedBox(height: 16),
          _passcodeRow(
            Icons.room_service_outlined,
            'Waiter',
            codes['waiter'] ?? '',
          ),
          const SizedBox(height: 8),
          _passcodeRow(
            Icons.restaurant_outlined,
            'Kitchen',
            codes['kitchen'] ?? '',
          ),
          const SizedBox(height: 8),
          _passcodeRow(
            Icons.admin_panel_settings_outlined,
            'Admin',
            codes['admin'] ?? '',
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

Widget _passcodeRow(IconData icon, String label, String code, {double? fontSize}) {
  return Row(
    children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 10),
      Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
      Flexible(
        child: Text(
          code,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize ?? 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ),
    ],
  );
}
