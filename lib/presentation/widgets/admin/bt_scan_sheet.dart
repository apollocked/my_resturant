import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
  final status = await Permission.bluetooth.request();
  if (!status.isGranted) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth permission required')),
      );
    }
    return;
  }
  final state = FlutterBluePlus.adapterStateNow;
  if (state != BluetoothAdapterState.on && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bluetooth is off')),
    );
    return;
  }
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
    final printers =
        results.where((r) => r.advertisementData.advName.isNotEmpty).toList();
    if (printers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No devices found')),
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
        SnackBar(content: Text('Scan error: $e')),
      );
    }
  }
}
