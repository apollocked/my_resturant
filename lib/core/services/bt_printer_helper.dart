import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BtPrinterHelper {
  BluetoothDevice? device;
  BluetoothCharacteristic? char;

  Future<bool> connect(String mac) async {
    try {
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
    final data = bytes is List<int> ? bytes : bytes;
    const chunkSize = 200;
    for (var i = 0; i < data.length; i += chunkSize) {
      final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      await char!.write(data.sublist(i, end), withoutResponse: true);
    }
    return true;
  }
}
