import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';

Future<void> showPasscodesSavedDialog(
  BuildContext context,
  Map<String, String> codes,
) async {
  final locale = context.read<SettingsCubit>().state.locale;
  String t(String key) => Tr.get(key, locale);
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      scrollable: true,
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 28),
          const SizedBox(width: 10),
          Text(t('passcodes_saved_title')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t('passcodes_saved_body')),
          const SizedBox(height: 16),
          _passcodeRow(
            Icons.room_service_outlined,
            t('waiter'),
            codes['waiter'] ?? '',
          ),
          const SizedBox(height: 8),
          _passcodeRow(
            Icons.restaurant_outlined,
            t('kitchen'),
            codes['kitchen'] ?? '',
          ),
          const SizedBox(height: 8),
          _passcodeRow(
            Icons.admin_panel_settings_outlined,
            t('admin'),
            codes['admin'] ?? '',
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(t('got_it')),
        ),
      ],
    ),
  );
}

Widget _passcodeRow(IconData icon, String label, String code, {double? fontSize}) {
  return Row(
    children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 10),
      Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
      Flexible(
        child: Text(
          code,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize ?? 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ),
    ],
  );
}
