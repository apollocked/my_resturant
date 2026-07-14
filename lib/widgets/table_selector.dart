import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/cubits/settings_cubit.dart';
import 'package:my_resturant/l10n/tr.dart';
import 'package:my_resturant/theme/app_theme.dart';

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
          color: AppTheme.primarySoft, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(selectedTable == 0 ? t('choose') : '${t('table')} $selectedTable',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primary)),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more, color: AppTheme.primary, size: 18),
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
              backgroundColor: locked ? cs.surfaceContainerHighest : (sel ? AppTheme.primary : cs.surface),
              foregroundColor: locked ? cs.onSurfaceVariant : (sel ? cs.onPrimary : AppTheme.textPrimary),
              side: BorderSide(color: locked ? cs.outlineVariant : (sel ? AppTheme.primary : cs.outlineVariant)),
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
