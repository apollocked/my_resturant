import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

/// Wraps [PrinterManager] to expose a single connect/scan/send facade for all
/// supported handheld ESC/POS transports (Bluetooth Classic SPP, BLE, USB-OTG,
/// and Network TCP/IP). The byte stream for a receipt is produced elsewhere and
/// pushed through [send].
class PrinterTransport {
  final _manager = PrinterManager();

  bool _connected = false;
  bool get isConnected => _manager.isConnected || _connected;

  Stream<PrinterConnectionState> get stateStream => _manager.stateStream;

  Future<bool> ensurePermission() async {
    if (kIsWeb) return false;
    final status = await Permission.bluetooth.request();
    return status.isGranted;
  }

  Future<bool> connect({
    required ConnectionKind kind,
    String? host,
    int port = 9100,
    String? mac,
  }) async {
    try {
      await disconnect();
      if (kind == ConnectionKind.none) return false;
      if (!kIsWeb && Platform.isAndroid) {
        final status = await Permission.bluetooth.request();
        if (!status.isGranted) return false;
      }
      PrinterDevice? device;
      switch (kind) {
        case ConnectionKind.network:
          device = NetworkPrinterDevice(name: host ?? 'network', host: host ?? '', port: port);
        case ConnectionKind.bluetooth:
          device = BluetoothPrinterDevice(name: mac ?? 'bluetooth', address: mac ?? '');
        case ConnectionKind.ble:
          device = BlePrinterDevice(name: mac ?? 'ble', deviceId: mac ?? '');
        case ConnectionKind.usb:
          device = await _discoverUsb();
        case ConnectionKind.none:
          device = null;
      }
      if (device == null) return false;
      try {
        await _manager.connect(device);
      } catch (e) {
        // Handhelds may expose only BLE (not Classic SPP). Retry over BLE
        // before failing the whole connect.
        if (kind == ConnectionKind.bluetooth && mac != null) {
          _connected = false;
          final viaBle = await connect(kind: ConnectionKind.ble, mac: mac);
          return viaBle;
        }
        rethrow;
      }
      _connected = true;
      return true;
    } catch (_) {
      _connected = false;
      return false;
    }
  }

  /// Picks the first USB printer attached via OTG. The dialog shown on first
  /// connect is handled natively by the transport.
  Future<UsbPrinterDevice?> _discoverUsb() async {
    try {
      final found = await _manager.scanPrinters(
        types: const {PrinterConnectionType.usb},
        timeout: const Duration(seconds: 3),
      );
      if (found.isEmpty) return null;
      final usb = found.firstWhere(
        (d) => d is UsbPrinterDevice,
        orElse: () => found.first,
      );
      return usb is UsbPrinterDevice ? usb : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> disconnect() async {
    _connected = false;
    try {
      await _manager.disconnect();
    } catch (_) {}
  }

  Future<bool> send(List<int> bytes) async {
    if (!isConnected) return false;
    try {
      await _manager.printBytes(bytes);
      await _manager.waitWriteComplete();
      return true;
    } catch (_) {
      _connected = false;
      return false;
    }
  }

  /// Scans for discoverable Bluetooth printers (Classic SPP + BLE).
  Future<List<PrinterDevice>> scanPrinters({Duration? timeout}) async {
    try {
      return await _manager.scanPrinters(
        types: const {PrinterConnectionType.bluetooth, PrinterConnectionType.ble},
        timeout: timeout ?? const Duration(seconds: 5),
      );
    } catch (_) {
      return const [];
    }
  }

  void dispose() {
    disconnect();
    _manager.dispose();
  }
}

/// Returns the transport-specific identifier for a discovered printer
/// (MAC for Classic/BLE, host for network, VID:PID for USB). Falls back to
/// the device name when no address applies.
String printerAddress(PrinterDevice d) {
  if (d is BluetoothPrinterDevice) return d.address;
  if (d is BlePrinterDevice) return d.deviceId;
  if (d is NetworkPrinterDevice) return '${d.host}:${d.port}';
  if (d is UsbPrinterDevice) return d.identifier;
  return d.name;
}

/// Transport kinds exposed to the app mapping 1:1 with the connection types
/// a handheld printer may support.
enum ConnectionKind { network, bluetooth, ble, usb, none }