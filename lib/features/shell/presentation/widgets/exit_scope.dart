import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class ExitScope extends StatelessWidget {
  const ExitScope({super.key, required this.t, required this.child});

  final String Function(String) t;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit(context, t);
      },
      child: child,
    );
  }

  Future<void> _confirmExit(
    BuildContext context,
    String Function(String) t,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('app_name')),
        content: Text(t('exit_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              t('exit'),
              style: TextStyle(color: Theme.of(ctx).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) SystemNavigator.pop();
  }
}
