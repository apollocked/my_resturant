import 'package:flutter/material.dart';

/// The reusable "scan for printers" button. Shows a radar sweep icon while
/// scanning and swaps to [scanningLabel] when one is provided.
class PrinterScanButton extends StatelessWidget {
  final bool scanning;
  final VoidCallback onScan;
  final String label;
  final String? scanningLabel;

  const PrinterScanButton({
    super.key,
    required this.scanning,
    required this.onScan,
    required this.label,
    this.scanningLabel,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: scanning ? null : onScan,
      icon: Icon(scanning ? Icons.radar : Icons.search, size: 20),
      label: Text(scanning ? (scanningLabel ?? label) : label),
    );
  }
}