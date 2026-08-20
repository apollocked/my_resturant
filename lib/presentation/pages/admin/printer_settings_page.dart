import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/services/printer_config.dart';
import 'package:my_resturant/presentation/cubits/printer_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});
  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  late PrinterConnectionType _type;
  late TextEditingController _hostCtl;
  late TextEditingController _portCtl;
  late TextEditingController _macCtl;
  late TextEditingController _nameCtl;
  late int _paperWidth;
  late bool _autoKitchen;

  @override
  void initState() {
    super.initState();
    final cfg = context.read<PrinterCubit>().state.config;
    _type = cfg.connectionType;
    _hostCtl = TextEditingController(text: cfg.host);
    _portCtl = TextEditingController(text: cfg.port.toString());
    _macCtl = TextEditingController(text: cfg.macAddress ?? '');
    _nameCtl = TextEditingController(text: cfg.restaurantName);
    _paperWidth = cfg.paperWidth;
    _autoKitchen = cfg.autoPrintKitchen;
  }

  @override
  void dispose() {
    _hostCtl.dispose();
    _portCtl.dispose();
    _macCtl.dispose();
    _nameCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final printer = context.watch<PrinterCubit>();
    final connected = printer.state.isConnected;
    final p = R.padding(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('printer_settings')),
        actions: [
          if (connected)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.link, color: cs.success, size: 20),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(p),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(t('connection_type'), cs),
                  const SizedBox(height: 8),
                  _typeSelector(cs),
                  const SizedBox(height: 20),
                  if (_type == PrinterConnectionType.network) ...[
                    _sectionTitle(t('host_ip'), cs),
                    const SizedBox(height: 8),
                    _field(_hostCtl, Icons.dns, '192.168.1.100'),
                    const SizedBox(height: 12),
                    _sectionTitle(t('port'), cs),
                    const SizedBox(height: 8),
                    _field(_portCtl, Icons.tag, '9100'),
                  ],
                  if (_type == PrinterConnectionType.bluetooth) ...[
                    _sectionTitle(t('mac_address'), cs),
                    const SizedBox(height: 8),
                    _field(_macCtl, Icons.bluetooth, 'AA:BB:CC:DD:EE:FF'),
                  ],
                  const SizedBox(height: 20),
                  _sectionTitle(t('restaurant_name'), cs),
                  const SizedBox(height: 8),
                  _field(_nameCtl, Icons.store, t('restaurant_name')),
                  const SizedBox(height: 16),
                  _sectionTitle(t('paper_size'), cs),
                  const SizedBox(height: 8),
                  _paperSelector(cs),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t('auto_print_kitchen'),
                          style: TextStyle(
                            fontSize: R.fontMd(context),
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      Switch(
                        value: _autoKitchen,
                        onChanged: (v) => setState(() => _autoKitchen = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildConnectButton(printer, cs),
                  const SizedBox(height: 12),
                  _buildTestButton(printer, cs),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, ColorScheme cs) => Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 13,
      color: cs.onSurfaceVariant,
    ),
  );

  Widget _typeSelector(ColorScheme cs) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PrinterConnectionType.values.map((t) {
        final selected = _type == t;
        final icon = switch (t) {
          PrinterConnectionType.network => Icons.wifi,
          PrinterConnectionType.bluetooth => Icons.bluetooth,
          PrinterConnectionType.sunmi => Icons.phone_android,
          PrinterConnectionType.none => Icons.power_off,
        };
        final label = switch (t) {
          PrinterConnectionType.network => 'WiFi/LAN',
          PrinterConnectionType.bluetooth => 'Bluetooth',
          PrinterConnectionType.sunmi => 'Sunmi',
          PrinterConnectionType.none => 'Disabled',
        };
        return ChoiceChip(
          avatar: Icon(icon, size: 18),
          label: Text(label),
          selected: selected,
          onSelected: (_) => setState(() => _type = t),
          selectedColor: cs.primary.withValues(alpha: 0.15),
        );
      }).toList(),
    );
  }

  Widget _field(
    TextEditingController ctl,
    IconData icon,
    String hint,
  ) {
    return TextField(
      controller: ctl,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20),
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _paperSelector(ColorScheme cs) {
    return Row(
      children: [58, 80].map((w) {
        final selected = _paperWidth == w;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text('${w}mm'),
            selected: selected,
            onSelected: (_) => setState(() => _paperWidth = w),
            selectedColor: cs.primary.withValues(alpha: 0.15),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConnectButton(PrinterCubit cubit, ColorScheme cs) {
    final connected = cubit.state.isConnected;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () async {
          await _saveConfig(cubit);
          connected ? cubit.disconnect() : cubit.connect();
        },
        icon: Icon(connected ? Icons.link_off : Icons.link, size: 20),
        label: Text(connected ? 'Disconnect' : 'Connect'),
        style: FilledButton.styleFrom(
          backgroundColor: connected ? cs.error : cs.primary,
        ),
      ),
    );
  }

  Widget _buildTestButton(PrinterCubit cubit, ColorScheme cs) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: cubit.state.isConnected
            ? () async {
                await _saveConfig(cubit);
                final order = _dummyOrder();
                final ok = await cubit.printReceipt(order);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Test printed' : 'Print failed'),
                    ),
                  );
                }
              }
            : null,
        icon: const Icon(Icons.print, size: 20),
        label: Text(t('print_test')),
      ),
    );
  }

  Future<void> _saveConfig(PrinterCubit cubit) async {
    final config = PrinterConfig(
      connectionType: _type,
      host: _hostCtl.text.trim(),
      port: int.tryParse(_portCtl.text.trim()) ?? 9100,
      macAddress: _macCtl.text.trim().isEmpty ? null : _macCtl.text.trim(),
      paperWidth: _paperWidth,
      restaurantName: _nameCtl.text.trim(),
      autoPrintKitchen: _autoKitchen,
    );
    await cubit.updateConfig(config);
  }

  Order _dummyOrder() {
    return Order(
      id: 'test-001',
      tableNumber: 1,
      tableName: 'Table 1',
      items: [],
      trackingCode: 'TEST',
    );
  }

  String t(String key) => Tr.get(key, context.read<SettingsCubit>().state.locale);
}
