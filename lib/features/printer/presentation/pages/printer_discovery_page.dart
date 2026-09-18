import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/features/printer/domain/entities/printer_config.dart';
import 'package:my_resturant/features/printer/data/printer_transport.dart';
import 'package:my_resturant/features/printer/presentation/cubits/printer_cubit.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/features/printer/presentation/widgets/printer_device_card.dart';
import 'package:my_resturant/features/printer/presentation/widgets/printer_scan_button.dart';
import 'package:my_resturant/features/printer/presentation/widgets/printer_scan_prompt.dart';
import 'package:my_resturant/shared/empty_state.dart';
import 'package:my_resturant/features/permissions/presentation/permission_prompts.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart'
    hide PrinterConnectionType;

/// Lets the user search for nearby Bluetooth printers (Classic + BLE), pick
/// one, and pair/connect to it directly. Returns the paired address on pop.
class PrinterDiscoveryPage extends StatefulWidget {
  const PrinterDiscoveryPage({super.key});
  @override
  State<PrinterDiscoveryPage> createState() => _PrinterDiscoveryPageState();
}

class _PrinterDiscoveryPageState extends State<PrinterDiscoveryPage> {
  bool _scanning = false;
  bool _pairing = false;
  List<PrinterDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scan());
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
                    scanning: _scanning,
                    t: t,
                    onScan: _scan,
                  ),
                  const SizedBox(height: 20),
                  if (_devices.isNotEmpty) ...[
                    Text(
                      t('nearby_printers'),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: R.fontLg(context),
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._devices.map((d) => PrinterDeviceCard(
                          device: d,
                          pairing: _pairing,
                          onTap: () => _pair(t, d),
                        )),
                  ],
                  if (!_scanning && _devices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: EmptyState(
                        icon: Icons.bluetooth_searching,
                        title: t('bt_no_devices'),
                        subtitle: t('bt_no_devices_subtitle'),
                        action: PrinterScanButton(
                          scanning: _scanning,
                          onScan: _scan,
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

  Future<void> _scan() async {
    final settings = context.read<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final printer = context.read<PrinterCubit>();
    if (!kIsWeb) {
      final granted = await ensureBluetoothPermission(context);
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t('bt_permission_required'))),
          );
        }
        return;
      }
    }
    setState(() {
      _scanning = true;
      _devices = [];
    });
    try {
      final found = await printer.scan();
      if (!mounted) return;
      setState(() {
        _devices = found;
        _scanning = false;
      });
      if (found.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('bt_no_devices'))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _scanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('bt_scan_error').replaceAll('{error}', '$e'))),
      );
    }
  }

  Future<void> _pair(
    String Function(String) t,
    PrinterDevice device,
  ) async {
    final printer = context.read<PrinterCubit>();
    final address = printerAddress(device);
    setState(() => _pairing = true);
    await printer.updateConfig(
      printer.state.config.copyWith(
        connectionType: PrinterConnectionType.bluetooth,
        macAddress: address,
      ),
    );
    final ok = await printer.connect();
    if (!mounted) return;
    setState(() => _pairing = false);
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(t('printer_connected'))));
      Navigator.pop(context, address);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(t('printer_not_connected'))));
    }
  }
}