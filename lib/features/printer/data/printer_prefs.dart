import 'package:my_resturant/features/printer/domain/entities/printer_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and restores [PrinterConfig] from SharedPreferences.
class PrinterPrefs {
  static const _prefix = 'printer_';

  static Future<PrinterConfig> load() async {
    final p = await SharedPreferences.getInstance();
    final typeIdx = (p.getInt('${_prefix}type') ?? 0)
        .clamp(0, PrinterConnectionType.values.length - 1);
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