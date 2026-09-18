import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/features/printer/presentation/pages/printer_discovery_actions.dart';
import 'package:my_resturant/features/printer/presentation/widgets/printer_device_card.dart';
import 'package:my_resturant/features/printer/presentation/widgets/printer_scan_button.dart';
import 'package:my_resturant/features/printer/presentation/widgets/printer_scan_prompt.dart';
import 'package:my_resturant/shared/empty_state.dart';

/// Lets the user search for nearby Bluetooth printers (Classic + BLE), pick
/// one, and pair/connect to it directly. Returns the paired address on pop.
class PrinterDiscoveryPage extends StatefulWidget {
  const PrinterDiscoveryPage({super.key});
  @override
  State<PrinterDiscoveryPage> createState() => _PrinterDiscoveryPageState();
}

class _PrinterDiscoveryPageState extends State<PrinterDiscoveryPage>
    with PrinterDiscoveryActions {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => scan());
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final p = R.padding(context);

    return Scaffold(
      appBar: AppBar(title: Text(t('find_printer'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(p),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrinterScanPrompt(
                    scanning: scanning,
                    t: t,
                    onScan: scan,
                  ),
                  const SizedBox(height: 20),
                  if (devices.isNotEmpty) ...[
                    Text(
                      t('nearby_printers'),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: R.fontLg(context),
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...devices.map((d) => PrinterDeviceCard(
                          device: d,
                          pairing: pairing,
                          onTap: () => pair(t, d),
                        )),
                  ],
                  if (!scanning && devices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: EmptyState(
                        icon: Icons.bluetooth_searching,
                        title: t('bt_no_devices'),
                        subtitle: t('bt_no_devices_subtitle'),
                        action: PrinterScanButton(
                          scanning: scanning,
                          onScan: scan,
                          label: t('bt_scan'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}