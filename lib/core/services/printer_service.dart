import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:my_resturant/core/services/printer_config.dart';
import 'package:my_resturant/core/services/receipt_formatter.dart';
import 'package:my_resturant/domain/entities/order_model.dart';

class PrinterService {
  PrinterConfig _config = const PrinterConfig();
  PrinterConfig get config => _config;
  bool _connected = false;
  bool get isConnected => _connected;
  Socket? _socket;
  final _statusController = StreamController<bool>.broadcast();
  Stream<bool> get statusStream => _statusController.stream;

  Future<void> init() async {
    _config = await PrinterPrefs.load();
    if (_config.isConnected) {
      await connect();
    }
  }

  Future<void> updateConfig(PrinterConfig config) async {
    _config = config;
    await PrinterPrefs.save(config);
    await disconnect();
    if (config.isConnected) await connect();
  }

  Future<bool> connect() async {
    if (!_config.isConnected) return false;
    try {
      switch (_config.connectionType) {
        case PrinterConnectionType.network:
          return await _connectNetwork();
        case PrinterConnectionType.bluetooth:
          return await _connectBluetooth();
        case PrinterConnectionType.sunmi:
          return await _connectSunmi();
        case PrinterConnectionType.none:
          return false;
      }
    } catch (_) {
      _connected = false;
      _statusController.add(false);
      return false;
    }
  }

  Future<bool> _connectNetwork() async {
    if (_config.host.isEmpty) return false;
    try {
      _socket = await Socket.connect(
        _config.host,
        _config.port,
        timeout: const Duration(seconds: 5),
      );
      _connected = true;
      _statusController.add(true);
      return true;
    } catch (_) {
      _connected = false;
      _statusController.add(false);
      return false;
    }
  }

  Future<bool> _connectBluetooth() async {
    _connected = true;
    _statusController.add(true);
    return true;
  }

  Future<bool> _connectSunmi() async {
    _connected = true;
    _statusController.add(true);
    return true;
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
    _connected = false;
    _statusController.add(false);
  }

  Future<bool> printKitchenTicket(Order order) async {
    if (!_connected) {
      final ok = await connect();
      if (!ok) return false;
    }
    final bytes = ReceiptFormatter.kitchenTicket(order, _config);
    return await _sendBytes(bytes);
  }

  Future<bool> printFullReceipt(Order order) async {
    if (!_connected) {
      final ok = await connect();
      if (!ok) return false;
    }
    final bytes = ReceiptFormatter.fullReceipt(order, _config);
    return await _sendBytes(bytes);
  }

  Future<bool> _sendBytes(List<int> bytes) async {
    try {
      switch (_config.connectionType) {
        case PrinterConnectionType.network:
          return await _sendNetwork(bytes);
        case PrinterConnectionType.bluetooth:
          return await _sendBluetooth(bytes);
        case PrinterConnectionType.sunmi:
          return await _sendSunmi(bytes);
        case PrinterConnectionType.none:
          return false;
      }
    } catch (_) {
      _connected = false;
      _statusController.add(false);
      return false;
    }
  }

  Future<bool> _sendNetwork(List<int> bytes) async {
    if (_socket == null) return false;
    _socket!.add(bytes);
    await _socket!.flush();
    return true;
  }

  Future<bool> _sendBluetooth(List<int> bytes) async {
    if (kDebugMode) debugPrint('BT print: ${bytes.length} bytes');
    return true;
  }

  Future<bool> _sendSunmi(List<int> bytes) async {
    if (kDebugMode) debugPrint('Sunmi print: ${bytes.length} bytes');
    return true;
  }

  void dispose() {
    disconnect();
    _statusController.close();
  }
}
