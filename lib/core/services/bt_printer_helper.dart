import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BtPrinterHelper {
  BluetoothDevice? device;
  BluetoothCharacteristic? char;

  Future<bool> ensurePermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.bluetooth.request();
        if (!status.isGranted) return false;
      }
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on &&
          !kIsWeb) {
        await FlutterBluePlus.turnOn();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> connect(String mac) async {
    try {
      if (!await ensurePermission()) return false;
      device = BluetoothDevice(remoteId: DeviceIdentifier(mac));
      await device!.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 10),
      );
      final services = await device!.discoverServices();
      for (final s in services) {
        for (final c in s.characteristics) {
          if (c.properties.write || c.properties.writeWithoutResponse) {
            char = c;
            break;
          }
        }
        if (char != null) break;
      }
      if (char == null) {
        await device!.disconnect();
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await device?.disconnect();
    } catch (_) {}
    device = null;
    char = null;
  }

  Future<bool> send(List<int> bytes) async {
    if (char == null) return false;
    const chunkSize = 200;
    for (var i = 0; i < bytes.length; i += chunkSize) {
      final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      await char!.write(bytes.sublist(i, end), withoutResponse: true);
    }
    return true;
  }
}