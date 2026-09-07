import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/services/printer_config.dart';
import 'package:my_resturant/core/services/printer_transport.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/printer_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/permissions/permission_prompts.dart';
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
                  Text(
                    t('find_printer_sub'),
                    style: TextStyle(
                      fontSize: R.fontMd(context),
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _scanning ? null : _scan,
                      icon: Icon(_scanning ? Icons.radar : Icons.search, size: 20),
                      label: Text(_scanning ? t('bt_scanning') : t('scan_again')),
                    ),
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
                    ..._devices.map((d) => _deviceCard(context, t, d)),
                  ],
                  if (!_scanning && _devices.isEmpty)
                    _emptyState(context, t, cs),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _deviceCard(BuildContext context, String Function(String) t, PrinterDevice d) {
    final cs = Theme.of(context).colorScheme;
    final isBle = d is BlePrinterDevice;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          enabled: !_pairing,
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
            d.name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: R.fontMd(context),
              color: cs.onSurface,
            ),
          ),
          subtitle: Text(
            printerAddress(d),
            style: TextStyle(fontSize: R.fontSm(context), color: cs.onSurfaceVariant),
          ),
          trailing: _pairing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.link, color: AppColors.primary),
          onTap: _pairing ? null : () => _pair(t, d),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, String Function(String) t, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(Icons.bluetooth_searching, size: 56, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            t('bt_no_devices'),
            style: TextStyle(fontSize: R.fontMd(context), color: cs.onSurface),
          ),
        ],
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