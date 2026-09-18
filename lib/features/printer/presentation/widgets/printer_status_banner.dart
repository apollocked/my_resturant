import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/features/printer/domain/entities/printer_config.dart';
import 'package:my_resturant/features/printer/presentation/cubits/printer_cubit.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';

/// Live printer status row: connected / not connected / disabled, driven by
/// the current [connectionType] and the [PrinterCubit] connection state.
class PrinterStatusBanner extends StatelessWidget {
  const PrinterStatusBanner({super.key, required this.connectionType});
  final PrinterConnectionType connectionType;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final connected = context.watch<PrinterCubit>().state.isConnected;
    final disabled = connectionType == PrinterConnectionType.none;
    final ok = !disabled && connected;

    final (color, icon, text) = disabled
        ? (cs.outlineVariant, Icons.power_off, t('conn_disabled'))
        : ok
            ? (Colors.green, Icons.link, t('printer_connected'))
            : (cs.error, Icons.link_off, t('printer_not_connected'));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}