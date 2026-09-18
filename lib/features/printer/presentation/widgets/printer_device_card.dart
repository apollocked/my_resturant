import 'package:flutter/material.dart';

import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/features/printer/data/printer_transport.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart'
    hide PrinterConnectionType;

/// A tappable row for one discovered Bluetooth printer. While pairing, the
/// tile is disabled and shows an inline spinner.
class PrinterDeviceCard extends StatelessWidget {
  final PrinterDevice device;
  final bool pairing;
  final VoidCallback onTap;

  const PrinterDeviceCard({
    super.key,
    required this.device,
    required this.pairing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isBle = device is BlePrinterDevice;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          enabled: !pairing,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.softSurface(context),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              isBle ? Icons.bluetooth : Icons.print_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          title: Text(
            device.name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: R.fontMd(context),
              color: cs.onSurface,
            ),
          ),
          subtitle: Text(
            printerAddress(device),
            style: TextStyle(fontSize: R.fontSm(context), color: cs.onSurfaceVariant),
          ),
          trailing: pairing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.link, color: AppColors.primary),
          onTap: pairing ? null : onTap,
        ),
      ),
    );
  }
}