import 'dart:async';
import 'dart:io';
import 'package:my_resturant/core/services/bt_printer_helper.dart';
import 'package:my_resturant/core/services/printer_config.dart';
import 'package:my_resturant/core/services/receipt_formatter.dart';
import 'package:my_resturant/domain/entities/order_model.dart';

class PrinterService {
  PrinterConfig _config = const PrinterConfig();
  PrinterConfig get config => _config;
  bool _connected = false;
  bool get isConnected => _connected;
  Socket? _socket;
  final _bt = BtPrinterHelper();
  final _statusController = StreamController<bool>.broadcast();
  Stream<bool> get statusStream => _statusController.stream;

  Future<void> init() async {
    _config = await PrinterPrefs.load();
    if (_config.isConnected) await connect();
  }

  Future<void> updateConfig(PrinterConfig config) async {
    _config = config;
    await PrinterPrefs.save(config);
    await disconnect();
    if (config.isConnected) await connect();
  }

  Future<bool> connect() async {
    if (_config.connectionType == PrinterConnectionType.none) return false;
    try {
      switch (_config.connectionType) {
        case PrinterConnectionType.network:
          return await _connectNetwork();
        case PrinterConnectionType.bluetooth:
          return await _connectBluetooth();
        case PrinterConnectionType.sunmi:
          _connected = true;
          _statusController.add(true);
          return true;
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
        _config.host, _config.port,
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
    final mac = _config.macAddress?.trim() ?? '';
    if (mac.isEmpty) return false;
    final ok = await _bt.connect(mac);
    _connected = ok;
    _statusController.add(ok);
    return ok;
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
    await _bt.disconnect();
    _connected = false;
    _statusController.add(false);
  }

  Future<bool> printKitchenTicket(Order order) async {
    if (!_connected && !await connect()) return false;
    return await _sendBytes(ReceiptFormatter.kitchenTicket(order, _config));
  }

  Future<bool> printFullReceipt(Order order) async {
    if (!_connected && !await connect()) return false;
    return await _sendBytes(ReceiptFormatter.fullReceipt(order, _config));
  }

  Future<bool> _sendBytes(List<int> bytes) async {
    try {
      switch (_config.connectionType) {
        case PrinterConnectionType.network:
          if (_socket == null) return false;
          _socket!.add(bytes);
          await _socket!.flush();
          return true;
        case PrinterConnectionType.bluetooth:
          return await _bt.send(bytes);
        case PrinterConnectionType.sunmi:
          return true;
        case PrinterConnectionType.none:
          return false;
      }
    } catch (_) {
      _connected = false;
      _statusController.add(false);
      return false;
    }
  }

  void dispose() {
    disconnect();
    _statusController.close();
  }
}
