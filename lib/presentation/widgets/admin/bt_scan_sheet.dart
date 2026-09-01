import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/services/printer_transport.dart';
import 'package:my_resturant/presentation/cubits/printer_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart'
    hide PrinterConnectionType;

class PrinterDeviceSheet extends StatelessWidget {
  const PrinterDeviceSheet({super.key, required this.devices, required this.onPick});
  final List<PrinterDevice> devices;
  final ValueChanged<PrinterDevice> onPick;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: devices.length,
        itemBuilder: (_, i) {
          final d = devices[i];
          return ListTile(
            leading: const Icon(Icons.print),
            title: Text(d.name),
            subtitle: Text(printerAddress(d)),
            onTap: () => onPick(d),
          );
        },
      ),
    );
  }
}

/// Scans for discoverable printers (Bluetooth Classic + BLE) and lets the user
/// pick one, writing its identifier into [macCtl].
Future<void> scanBluetooth(
  BuildContext context,
  TextEditingController macCtl,
) async {
  final settings = context.read<SettingsCubit>().state;
  String t(String key) => Tr.get(key, settings.locale);
  final status = await Permission.bluetooth.request();
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  if (!status.isGranted) {
    messenger.showSnackBar(SnackBar(content: Text(t('bt_permission_required'))));
    return;
  }
  final printer = context.read<PrinterCubit>();
  messenger.showSnackBar(SnackBar(content: Text(t('bt_scanning'))));
  try {
    final devices = await printer.scan();
    if (!context.mounted) {
      return;
    }
    if (devices.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(t('bt_no_devices'))));
      return;
    }
    final selected = await showModalBottomSheet<PrinterDevice>(
      context: context,
      builder: (_) => PrinterDeviceSheet(
        devices: devices,
        onPick: (d) => Navigator.pop(context, d),
      ),
    );
    if (selected != null && context.mounted) {
      macCtl.text = printerAddress(selected);
    }
  } catch (e) {
    if (context.mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(t('bt_scan_error').replaceAll('{error}', '$e')),
        ),
      );
    }
  }
}