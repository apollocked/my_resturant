import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key, required this.t});

  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t('logout')),
      content: Text(t('logout_confirm')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t('cancel')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            t('logout'),
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }
}
