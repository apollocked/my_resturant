import 'dart:math';
import 'package:flutter/material.dart';

String _generateCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rng = Random.secure();
  return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
}

Future<Map<String, dynamic>?> showCreatePromoCodeDialog(
  BuildContext context,
) async {
  final controller = TextEditingController();
  int selectedMonths = 12;
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        scrollable: true,
        title: const Text('New Promo Code'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Enter code or tap generate',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.casino_outlined, size: 20),
                    tooltip: 'Generate random',
                    onPressed: () {
                      controller.text = _generateCode();
                      controller.selection = TextSelection.collapsed(
                        offset: controller.text.length,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: selectedMonths,
                decoration: const InputDecoration(
                  labelText: 'Expires in',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 3, child: Text('3 Months')),
                  DropdownMenuItem(value: 6, child: Text('6 Months')),
                  DropdownMenuItem(value: 12, child: Text('1 Year')),
                ],
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedMonths = v);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx, {
                'code': controller.text.trim().toUpperCase(),
                'months': selectedMonths,
              });
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );
}

Future<bool?> showDeletePromoCodeDialog(BuildContext context, String code) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Code?'),
      content: Text('Delete promo code "$code"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
