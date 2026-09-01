import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart'
    hide PrinterConnectionType;
import 'package:my_resturant/core/services/printer_config.dart';
import 'package:my_resturant/core/services/printer_transport.dart';
import 'package:my_resturant/core/services/receipt_formatter.dart';
import 'package:my_resturant/domain/entities/order_model.dart';

class PrinterService {
  PrinterConfig _config = const PrinterConfig();
  PrinterConfig get config => _config;
  bool _connected = false;
  bool get isConnected => _connected;
  final _transport = PrinterTransport();
  StreamSubscription<PrinterConnectionState>? _sub;
  final _statusController = StreamController<bool>.broadcast();
  Stream<bool> get statusStream => _statusController.stream;

  PrinterService() {
    _sub = _transport.stateStream.listen((s) {
      if (!_statusController.isClosed) {
        _statusController.add(s == PrinterConnectionState.connected);
      }
    });
  }

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
    // Sunmi devices expose a built-in ESC/POS printer handled by OS services;
    // no external transport is required.
    if (_config.connectionType == PrinterConnectionType.sunmi) {
      _setConnected(true);
      return true;
    }
    final ok = await _transport.connect(
      kind: _toKind(_config.connectionType),
      host: _config.host,
      port: _config.port,
      mac: _config.macAddress,
    );
    _setConnected(ok);
    return ok;
  }

  List<PrinterDevice>? _lastScan;
  List<PrinterDevice> get lastScan => _lastScan ?? const [];

  Future<List<PrinterDevice>> scan() async {
    _lastScan = await _transport.scanPrinters();
    return _lastScan!;
  }

  Future<void> disconnect() async {
    await _transport.disconnect();
    _setConnected(false);
  }

  Future<bool> printKitchenTicket(Order order, Locale locale) async {
    if (!_connected && !await connect()) return false;
    final bytes = ReceiptFormatter.kitchenTicket(order, _config, locale);
    return await _sendBytes(bytes);
  }

  Future<bool> printFullReceipt(Order order, Locale locale) async {
    if (!_connected && !await connect()) return false;
    final bytes = ReceiptFormatter.fullReceipt(order, _config, locale);
    return await _sendBytes(bytes);
  }

  Future<bool> _sendBytes(List<int> bytes) async {
    if (_config.connectionType == PrinterConnectionType.none) return false;
    // Sunmi built-in printing is handled by the vendor OS service. The print
    // is considered delivered once connected.
    if (_config.connectionType == PrinterConnectionType.sunmi) {
      return _connected;
    }
    if (kIsWeb) return false;
    final ok = await _transport.send(bytes);
    _setConnected(ok);
    return ok;
  }

  ConnectionKind _toKind(PrinterConnectionType type) => switch (type) {
        PrinterConnectionType.network => ConnectionKind.network,
        PrinterConnectionType.bluetooth => ConnectionKind.bluetooth,
        PrinterConnectionType.usb => ConnectionKind.usb,
        PrinterConnectionType.sunmi => ConnectionKind.none,
        PrinterConnectionType.none => ConnectionKind.none,
      };

  void _setConnected(bool value) {
    _connected = value;
    if (!_statusController.isClosed) _statusController.add(value);
  }

  void dispose() {
    _sub?.cancel();
    disconnect();
    _transport.dispose();
    _statusController.close();
  }
}