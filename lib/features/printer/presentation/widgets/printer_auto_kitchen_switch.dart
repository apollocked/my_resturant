import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';

/// Row that toggles whether kitchen receipts auto-print.
class PrinterAutoKitchenSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const PrinterAutoKitchenSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            Tr.get('auto_print_kitchen', context.read<SettingsCubit>().state.locale),
            style: TextStyle(fontSize: R.fontMd(context), color: cs.onSurface),
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}