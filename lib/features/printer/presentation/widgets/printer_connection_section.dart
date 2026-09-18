import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/features/printer/domain/entities/printer_config.dart';
import 'package:my_resturant/features/printer/presentation/cubits/printer_cubit.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/features/printer/presentation/widgets/bt_scan_sheet.dart';
import 'package:my_resturant/features/printer/presentation/widgets/printer_status_banner.dart';

class PrinterConnectionSection extends StatelessWidget {
  const PrinterConnectionSection({
    super.key,
    required this.type,
    required this.hostCtl,
    required this.portCtl,
    required this.macCtl,
    required this.onTypeChanged,
  });

  final PrinterConnectionType type;
  final TextEditingController hostCtl;
  final TextEditingController portCtl;
  final TextEditingController macCtl;
  final ValueChanged<PrinterConnectionType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(t('connection_type'), cs),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PrinterConnectionType.values.map((ct) {
            final selected = type == ct;
            final icon = switch (ct) {
              PrinterConnectionType.network => Icons.wifi,
              PrinterConnectionType.bluetooth => Icons.bluetooth,
              PrinterConnectionType.usb => Icons.usb,
              PrinterConnectionType.sunmi => Icons.phone_android,
              PrinterConnectionType.none => Icons.power_off,
            };
            final label = switch (ct) {
              PrinterConnectionType.network => t('conn_wifi_lan'),
              PrinterConnectionType.bluetooth => t('conn_bluetooth'),
              PrinterConnectionType.usb => t('conn_usb'),
              PrinterConnectionType.sunmi => t('conn_sunmi'),
              PrinterConnectionType.none => t('conn_disabled'),
            };
            return ChoiceChip(
              avatar: Icon(icon, size: 18),
              label: Text(label),
              selected: selected,
              onSelected: (_) => onTypeChanged(ct),
              selectedColor: cs.primary.withValues(alpha: 0.15),
            );
          }).toList(),
        ),
        if (type == PrinterConnectionType.network) ...[
          const SizedBox(height: 20),
          _label(t('host_ip'), cs),
          const SizedBox(height: 8),
          _field(hostCtl, Icons.dns, '192.168.1.100'),
          const SizedBox(height: 12),
          _label(t('port'), cs),
          const SizedBox(height: 8),
          _field(portCtl, Icons.tag, '9100'),
        ],
        if (type == PrinterConnectionType.bluetooth) ...[
          const SizedBox(height: 20),
          _label(t('mac_address'), cs),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _field(macCtl, Icons.bluetooth, 'AA:BB:CC:DD:EE:FF')),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: () => scanBluetooth(context, macCtl),
                icon: const Icon(Icons.radar, size: 18),
                label: Text(t('bt_scan')),
              ),
            ],
          ),
        ],
        if (type == PrinterConnectionType.usb) ...[
          const SizedBox(height: 20),
          _label(t('usb_hint'), cs),
        ],
        const SizedBox(height: 20),
        PrinterStatusBanner(connectionType: type),
      ],
    );
  }

  static Widget _label(String text, ColorScheme cs) => Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 13,
      color: cs.onSurfaceVariant,
    ),
  );

  static Widget _field(TextEditingController ctl, IconData icon, String hint) {
    return TextField(
      controller: ctl,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20),
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}
