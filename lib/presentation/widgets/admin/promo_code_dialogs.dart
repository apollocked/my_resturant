import 'dart:math';
import 'package:flutter/material.dart';

String _generateCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rng = Random.secure();
  return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
}

Future<Map<String, dynamic>?> showCreatePromoCodeDialog(
  BuildContext context,
  String Function(String) t,
) async {
  final controller = TextEditingController();
  int selectedMonths = 12;
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        scrollable: true,
        title: Text(t('promo_new_title')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: t('promo_hint'),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.casino_outlined, size: 20),
                    tooltip: t('promo_generate'),
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
                decoration: InputDecoration(
                  labelText: t('promo_expires_in'),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 3, child: Text(t('months_3'))),
                  DropdownMenuItem(value: 6, child: Text(t('months_6'))),
                  DropdownMenuItem(value: 12, child: Text(t('months_12'))),
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
            child: Text(t('cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx, {
                'code': controller.text.trim().toUpperCase(),
                'months': selectedMonths,
              });
            },
            child: Text(t('create')),
          ),
        ],
      ),
    ),
  );
}

Future<bool?> showDeletePromoCodeDialog(
  BuildContext context,
  String code,
  String Function(String) t,
) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t('promo_delete_title')),
      content: Text(t('promo_delete_confirm').replaceAll('{code}', code)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(t('cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(t('delete')),
        ),
      ],
    ),
  );
}
