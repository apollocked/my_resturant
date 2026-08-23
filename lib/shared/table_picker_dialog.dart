import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';

String _firstLetters(String s) {
  final trimmed = s.trim();
  if (trimmed.isEmpty) return '';
  return trimmed.split('').take(3).join();
}

Future<void> showTablePickerDialog(
  BuildContext context, {
  required int selectedTable,
  required ValueChanged<int> onChanged,
  required Set<int> reservedTables,
}) {
  final settings = context.read<SettingsCubit>();
  final cs = Theme.of(context).colorScheme;
  String t(String key) => Tr.get(key, settings.state.locale);
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t('select_table_title')),
      content: SingleChildScrollView(
        child: Builder(
          builder: (ctx2) {
            final orderState = context.read<OrderCubit>().state;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(orderState.tableCount, (i) {
                final n = i + 1;
                final sel = n == selectedTable;
                final locked = reservedTables.contains(n) && n != selectedTable;
                final customName = orderState.tableNames[n]?.trim();
                final hasCustom = customName != null && customName.isNotEmpty;
                final labelColor = sel ? cs.onPrimary : cs.onSurface;
                return SizedBox(
                  width: 56,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: locked
                        ? null
                        : () {
                            onChanged(n);
                            Navigator.pop(ctx);
                          },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: locked
                          ? cs.surfaceContainerHighest
                          : (sel ? AppColors.primary : cs.surface),
                      foregroundColor: locked
                          ? cs.onSurfaceVariant
                          : labelColor,
                      side: BorderSide(
                        color: locked
                            ? cs.outlineVariant
                            : (sel ? AppColors.primary : cs.outlineVariant),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: locked
                        ? Icon(
                            Icons.lock,
                            size: 14,
                            color: cs.onSurfaceVariant,
                          )
                        : hasCustom
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _firstLetters(customName),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: labelColor,
                                ),
                              ),
                              Text(
                                '$n',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                  color: sel
                                      ? cs.onPrimary.withValues(alpha: 0.85)
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '$n',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: R.fontSm(context),
                            ),
                          ),
                  ),
                );
              }),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(t('cancel')),
        ),
      ],
    ),
  );
}
