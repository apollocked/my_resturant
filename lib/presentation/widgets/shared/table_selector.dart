import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

class TableSelector extends StatelessWidget {
  final int selectedTable;
  final ValueChanged<int> onChanged;
  final Set<int> reservedTables;

  const TableSelector({super.key, required this.selectedTable, required this.onChanged, this.reservedTables = const {}});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    String t(String key) => Tr.get(key, settings.state.locale);
    return PressableScale(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(selectedTable == 0 ? t('choose') : 'Table $selectedTable',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more, color: AppColors.primary, size: 18),
        ]),
      ),
    );
  }

  String _firstLetters(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split('').take(3).join();
  }

  void _showPicker(BuildContext context) {
    final settings = context.read<SettingsCubit>();
    final cs = Theme.of(context).colorScheme;
    final isRtl = settings.state.locale.languageCode != 'en';
    String t(String key) => Tr.get(key, settings.state.locale);
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(t('select_table_title'), textAlign: isRtl ? TextAlign.right : TextAlign.left),
          content: SingleChildScrollView(
            child: Builder(builder: (ctx2) {
              final orderState = context.read<OrderCubit>().state;
              return Wrap(spacing: 10, runSpacing: 10, children: List.generate(orderState.tableCount, (i) {
                final n = i + 1;
                final sel = n == selectedTable;
                final locked = reservedTables.contains(n) && n != selectedTable;
                final customName = orderState.tableNames[n]?.trim();
                final hasCustom = customName != null && customName.isNotEmpty;
                final labelColor = sel ? cs.onPrimary : cs.onSurface;
                return SizedBox(width: 56, height: 44, child: OutlinedButton(
                  onPressed: locked ? null : () { onChanged(n); Navigator.pop(ctx); },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: locked ? cs.surfaceContainerHighest : (sel ? AppColors.primary : cs.surface),
                    foregroundColor: locked ? cs.onSurfaceVariant : labelColor,
                    side: BorderSide(color: locked ? cs.outlineVariant : (sel ? AppColors.primary : cs.outlineVariant)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: locked
                      ? Icon(Icons.lock, size: 14, color: cs.onSurfaceVariant)
                      : hasCustom
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_firstLetters(customName),
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: labelColor)),
                                Text('$n',
                                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500, color: sel ? cs.onPrimary.withValues(alpha: 0.85) : cs.onSurfaceVariant)),
                              ],
                            )
                          : Text('$n', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ));
              }));
            }),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('cancel')))],
        ),
      ),
    );
  }
}
