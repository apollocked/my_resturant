import 'package:flutter/material.dart';

import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/features/printer/presentation/widgets/printer_scan_button.dart';

/// The discovery page header: a short hint plus the full-width scan button.
class PrinterScanPrompt extends StatelessWidget {
  final bool scanning;
  final String Function(String) t;
  final VoidCallback onScan;

  const PrinterScanPrompt({
    super.key,
    required this.scanning,
    required this.t,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('find_printer_sub'),
          style: TextStyle(
            fontSize: R.fontMd(context),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: PrinterScanButton(
            scanning: scanning,
            onScan: onScan,
            label: t('scan_again'),
            scanningLabel: t('bt_scanning'),
          ),
        ),
      ],
    );
  }
}