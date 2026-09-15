enum PrinterConnectionType { network, bluetooth, usb, sunmi, none }

/// Immutable printer settings that describe how a receipt/kitchen ticket is
/// delivered. Kept free of any persistence/transport coupling so the domain can
/// reason about a printer without knowing where the settings came from.
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