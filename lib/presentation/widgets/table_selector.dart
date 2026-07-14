import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class TableSelector extends StatelessWidget {
  final int selectedTable;
  final ValueChanged<int> onChanged;
  final Set<int> reservedTables;

  const TableSelector({super.key, required this.selectedTable, required this.onChanged, this.reservedTables = const {}});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    String t(String key) => Tr.get(key, settings.state.locale);
    return InkWell(
      onTap: () => _showPicker(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(selectedTable == 0 ? t('choose') : '${t('table')} $selectedTable',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more, color: AppColors.primary, size: 18),
        ]),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final settings = context.read<SettingsCubit>();
    final cs = Theme.of(context).colorScheme;
    String t(String key) => Tr.get(key, settings.state.locale);
    showModalBottomSheet(context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4, decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text(t('select_table_title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        Wrap(spacing: 10, runSpacing: 10, children: List.generate(20, (i) {
          final n = i + 1;
          final sel = n == selectedTable;
          final locked = reservedTables.contains(n) && n != selectedTable;
          return SizedBox(width: 56, height: 44, child: OutlinedButton(
            onPressed: locked ? null : () { onChanged(n); Navigator.pop(ctx); },
            style: OutlinedButton.styleFrom(
              backgroundColor: locked ? cs.surfaceContainerHighest : (sel ? AppColors.primary : cs.surface),
              foregroundColor: locked ? cs.onSurfaceVariant : (sel ? cs.onPrimary : AppColors.textPrimary),
              side: BorderSide(color: locked ? cs.outlineVariant : (sel ? AppColors.primary : cs.outlineVariant)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: locked
                ? Icon(Icons.lock, size: 14, color: cs.onSurfaceVariant)
                : Text('$n', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ));
        })),
        const SizedBox(height: 12),
      ])),
    );
  }
}
