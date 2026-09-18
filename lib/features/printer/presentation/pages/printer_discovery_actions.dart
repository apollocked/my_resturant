import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/features/printer/data/printer_transport.dart';
import 'package:my_resturant/features/printer/domain/entities/printer_config.dart';
import 'package:my_resturant/features/printer/presentation/cubits/printer_cubit.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/features/permissions/presentation/permission_prompts.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart'
    hide PrinterConnectionType;

/// Bluetooth discovery + pairing flow for the printer discovery page.
///
/// Owns the scan state ([scanning], [pairing], [devices]) and triggers the
/// permission prompt, the scan, and the config + connect handshake when a
/// device is chosen.
mixin PrinterDiscoveryActions<T extends StatefulWidget> on State<T> {
  bool scanning = false;
  bool pairing = false;
  List<PrinterDevice> devices = [];

  Future<void> scan() async {
    final settings = context.read<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final printer = context.read<PrinterCubit>();
    if (!kIsWeb) {
      final granted = await ensureBluetoothPermission(context);
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t('bt_permission_required'))),
          );
        }
        return;
      }
    }
    setState(() {
      scanning = true;
      devices = [];
    });
    try {
      final found = await printer.scan();
      if (!mounted) return;
      setState(() {
        devices = found;
        scanning = false;
      });
      if (found.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('bt_no_devices'))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => scanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('bt_scan_error').replaceAll('{error}', '$e'))),
      );
    }
  }

  Future<void> pair(String Function(String) t, PrinterDevice device) async {
    final printer = context.read<PrinterCubit>();
    final address = printerAddress(device);
    setState(() => pairing = true);
    await printer.updateConfig(
      printer.state.config.copyWith(
        connectionType: PrinterConnectionType.bluetooth,
        macAddress: address,
      ),
    );
    final ok = await printer.connect();
    if (!mounted) return;
    setState(() => pairing = false);
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(t('printer_connected'))));
      Navigator.pop(context, address);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(t('printer_not_connected'))));
    }
  }
}