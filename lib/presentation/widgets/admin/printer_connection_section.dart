import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/services/printer_config.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';

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
              PrinterConnectionType.sunmi => Icons.phone_android,
              PrinterConnectionType.none => Icons.power_off,
            };
            final label = switch (ct) {
              PrinterConnectionType.network => 'WiFi/LAN',
              PrinterConnectionType.bluetooth => 'Bluetooth',
              PrinterConnectionType.sunmi => 'Sunmi',
              PrinterConnectionType.none => 'Disabled',
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
            children: [
              Expanded(
                child: _field(macCtl, Icons.bluetooth, 'AA:BB:CC:DD:EE:FF'),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () => _scanBt(context, macCtl),
                icon: const Icon(Icons.search, size: 20),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _scanBt(BuildContext context, TextEditingController macCtl) async {
    final settings = context.read<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    try {
      final isOn = await FlutterBluePlus.adapterStateNow;
      if (isOn != BluetoothAdapterState.on && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('printer_not_connected'))),
        );
        return;
      }
    } catch (_) {}
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scanning...')),
    );
    try {
      final results = <ScanResult>[];
      final sub = FlutterBluePlus.onScanResults.listen(results.addAll);
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      await sub.cancel();
      if (!context.mounted) return;
      final printers = results.where((r) => r.advertisementName.isNotEmpty).toList();
      if (printers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No devices found')),
        );
        return;
      }
      await showModalBottomSheet(
        context: context,
        builder: (ctx) => _btDeviceList(ctx, printers, macCtl),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan error: $e')),
        );
      }
    }
  }

  Widget _btDeviceList(BuildContext ctx, List<ScanResult> devices, TextEditingController macCtl) {
    return ListView.builder(
      itemCount: devices.length,
      shrinkWrap: true,
      itemBuilder: (_, i) {
        final d = devices[i];
        final name = d.advertisementName.isNotEmpty
            ? d.advertisementName
            : d.device.remoteId.str;
        return ListTile(
          leading: const Icon(Icons.bluetooth),
          title: Text(name),
          subtitle: Text(d.device.remoteId.str),
          onTap: () {
            macCtl.text = d.device.remoteId.str;
            Navigator.pop(ctx);
          },
        );
      },
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
