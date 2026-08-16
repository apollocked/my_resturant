import 'package:flutter/material.dart';

Future<void> showClearAllOrdersDialog(
  BuildContext context,
  String Function(String) t,
  VoidCallback onConfirm,
) async {
  final cs = Theme.of(context).colorScheme;
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 48),
      title: Text(t('clear_all_orders')),
      content: Text(t('clear_all_orders_confirm')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(t('cancel')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: cs.error),
          onPressed: () {
            Navigator.pop(ctx);
            onConfirm();
          },
          child: Text(t('clear'), style: TextStyle(color: cs.onError)),
        ),
      ],
    ),
  );
}
