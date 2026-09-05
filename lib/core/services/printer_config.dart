import 'package:shared_preferences/shared_preferences.dart';

enum PrinterConnectionType { network, bluetooth, usb, sunmi, none }

class PrinterConfig {
  final PrinterConnectionType connectionType;
  final String host;
  final int port;
  final String? macAddress;
  final int paperWidth;
  final String restaurantName;
  final bool autoPrintKitchen;

  const PrinterConfig({
    this.connectionType = PrinterConnectionType.none,
    this.host = '',
    this.port = 9100,
    this.macAddress,
    this.paperWidth = 80,
    this.restaurantName = '',
    this.autoPrintKitchen = true,
  });

  bool get isConnected => connectionType != PrinterConnectionType.none;

  PrinterConfig copyWith({
    PrinterConnectionType? connectionType,
    String? host,
    int? port,
    String? macAddress,
    int? paperWidth,
    String? restaurantName,
    bool? autoPrintKitchen,
  }) {
    return PrinterConfig(
      connectionType: connectionType ?? this.connectionType,
      host: host ?? this.host,
      port: port ?? this.port,
      macAddress: macAddress ?? this.macAddress,
      paperWidth: paperWidth ?? this.paperWidth,
      restaurantName: restaurantName ?? this.restaurantName,
      autoPrintKitchen: autoPrintKitchen ?? this.autoPrintKitchen,
    );
  }
}

class PrinterPrefs {
  static const _prefix = 'printer_';

  static Future<PrinterConfig> load() async {
    final p = await SharedPreferences.getInstance();
    final typeIdx = p.getInt('${_prefix}type') ?? 0;
    return PrinterConfig(
      connectionType: PrinterConnectionType.values[typeIdx],
      host: p.getString('${_prefix}host') ?? '',
      port: p.getInt('${_prefix}port') ?? 9100,
      macAddress: p.getString('${_prefix}mac'),
      paperWidth: p.getInt('${_prefix}paper') ?? 80,
      restaurantName: p.getString('${_prefix}name') ?? '',
      autoPrintKitchen: p.getBool('${_prefix}auto_kitchen') ?? true,
    );
  }

  static Future<void> save(PrinterConfig config) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('${_prefix}type', config.connectionType.index);
    await p.setString('${_prefix}host', config.host);
    await p.setInt('${_prefix}port', config.port);
    if (config.macAddress != null) {
      await p.setString('${_prefix}mac', config.macAddress!);
    }
    await p.setInt('${_prefix}paper', config.paperWidth);
    await p.setString('${_prefix}name', config.restaurantName);
    await p.setBool('${_prefix}auto_kitchen', config.autoPrintKitchen);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    for (final key in p.getKeys().where((k) => k.startsWith(_prefix))) {
      await p.remove(key);
    }
  }
}
