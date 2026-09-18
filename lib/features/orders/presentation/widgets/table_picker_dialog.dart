import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/features/orders/presentation/widgets/table_picker_cell.dart';
import 'package:my_resturant/shared/haptics.dart';

void _requestCleaning(BuildContext context, int n, String Function(String) t) {
  Haptics.added();
  context.read<OrderCubit>().requestCleaning(n);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(t('cleaning_request_sent').replaceAll('{table}', '$n')),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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
                final needsClean =
                    locked && orderState.needCleaningTables.contains(n);
                final requestedCleaning =
                    orderState.cleaningRequests.containsKey(n);
                final customName = orderState.tableNames[n]?.trim() ?? '';
                final hasCustom = customName.isNotEmpty;
                return TablePickerCell(
                  n: n,
                  selected: sel,
                  locked: locked,
                  needsClean: needsClean,
                  requestedCleaning: requestedCleaning,
                  hasCustomName: hasCustom,
                  customName: customName,
                  number: '$n',
                  cs: cs,
                  onPressed: needsClean
                      ? () => _requestCleaning(context, n, t)
                      : locked
                      ? null
                      : () {
                          onChanged(n);
                          Navigator.pop(ctx);
                        },
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