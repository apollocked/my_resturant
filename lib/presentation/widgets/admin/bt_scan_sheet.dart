import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

class BtScanSheet extends StatelessWidget {
  const BtScanSheet({super.key, required this.devices, required this.onPick});
  final List<ScanResult> devices;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: devices.length,
      shrinkWrap: true,
      itemBuilder: (_, i) {
        final d = devices[i];
        final name = d.advertisementData.advName.isNotEmpty
            ? d.advertisementData.advName
            : d.device.remoteId.str;
        return ListTile(
          leading: const Icon(Icons.bluetooth),
          title: Text(name),
          subtitle: Text(d.device.remoteId.str),
          onTap: () {
            onPick(d.device.remoteId.str);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

Future<void> scanBluetooth(
  BuildContext context,
  TextEditingController macCtl,
) async {
  final locale = context.read<SettingsCubit>().state.locale;
  String t(String key) => Tr.get(key, locale);
  final status = await Permission.bluetooth.request();
  if (!status.isGranted) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('bt_permission_required'))),
      );
    }
    return;
  }
  final state = FlutterBluePlus.adapterStateNow;
  if (state != BluetoothAdapterState.on && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t('bt_is_off'))),
    );
    return;
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t('bt_scanning'))),
  );
  try {
    final results = <ScanResult>[];
    final sub = FlutterBluePlus.onScanResults.listen(results.addAll);
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    await sub.cancel();
    if (!context.mounted) return;
    final printers =
        results.where((r) => r.advertisementData.advName.isNotEmpty).toList();
    if (printers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('bt_no_devices'))),
      );
      return;
    }
    await showModalBottomSheet(
      context: context,
      builder: (_) => BtScanSheet(
        devices: printers,
        onPick: (id) => macCtl.text = id,
      ),
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('bt_scan_error').replaceAll('{error}', '$e')),
        ),
      );
    }
  }
}
