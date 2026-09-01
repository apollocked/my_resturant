import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/shared/pressable_scale.dart';
import 'package:my_resturant/shared/table_picker_dialog.dart';

class TableSelector extends StatelessWidget {
  final int selectedTable;
  final ValueChanged<int> onChanged;
  final Set<int> reservedTables;

  const TableSelector({
    super.key,
    required this.selectedTable,
    required this.onChanged,
    this.reservedTables = const {},
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    String t(String key) => Tr.get(key, settings.state.locale);
    return PressableScale(
      onTap: () => showTablePickerDialog(
        context,
        selectedTable: selectedTable,
        onChanged: onChanged,
        reservedTables: reservedTables,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedTable == 0
                  ? t('choose')
                  : t('table_n').replaceAll('{n}', '$selectedTable'),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: R.fontSm(context),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
