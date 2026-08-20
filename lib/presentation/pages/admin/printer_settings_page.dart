import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/services/printer_config.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/printer_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/admin/printer_connection_section.dart';

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
    final p = R.padding(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('printer_settings')),
        actions: [
          if (printer.state.isConnected)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.link, color: Colors.green, size: 20),
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
                  PrinterConnectionSection(
                    type: _type,
                    hostCtl: _hostCtl,
                    portCtl: _portCtl,
                    macCtl: _macCtl,
                    onTypeChanged: (v) => setState(() => _type = v),
                  ),
                  const SizedBox(height: 20),
                  _label(t('restaurant_name_label'), cs),
                  const SizedBox(height: 8),
                  _field(_nameCtl, Icons.store, t('restaurant_name_label')),
                  const SizedBox(height: 16),
                  _label(t('paper_size'), cs),
                  const SizedBox(height: 8),
                  _paperSelector(cs),
                  const SizedBox(height: 16),
                  _autoKitchenRow(cs),
                  const SizedBox(height: 24),
                  _connectBtn(printer, cs),
                  const SizedBox(height: 12),
                  _testBtn(printer),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _autoKitchenRow(ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: Text(
            Tr.get('auto_print_kitchen', context.read<SettingsCubit>().state.locale),
            style: TextStyle(fontSize: R.fontMd(context), color: cs.onSurface),
          ),
        ),
        Switch(
          value: _autoKitchen,
          onChanged: (v) => setState(() => _autoKitchen = v),
        ),
      ],
    );
  }

  Widget _paperSelector(ColorScheme cs) {
    return Row(
      children: [58, 80].map((w) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text('${w}mm'),
            selected: _paperWidth == w,
            onSelected: (_) => setState(() => _paperWidth = w),
            selectedColor: cs.primary.withValues(alpha: 0.15),
          ),
        );
      }).toList(),
    );
  }

  Widget _connectBtn(PrinterCubit cubit, ColorScheme cs) {
    final connected = cubit.state.isConnected;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () async {
          await _save(cubit);
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

  Widget _testBtn(PrinterCubit cubit) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: cubit.state.isConnected
            ? () async {
                await _save(cubit);
                final ok = await cubit.printReceipt(_dummyOrder());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok ? 'Test printed' : 'Print failed')),
                  );
                }
              }
            : null,
        icon: const Icon(Icons.print, size: 20),
        label: Text(Tr.get('print_test', context.read<SettingsCubit>().state.locale)),
      ),
    );
  }

  Future<void> _save(PrinterCubit cubit) async {
    await cubit.updateConfig(PrinterConfig(
      connectionType: _type,
      host: _hostCtl.text.trim(),
      port: int.tryParse(_portCtl.text.trim()) ?? 9100,
      macAddress: _macCtl.text.trim().isEmpty ? null : _macCtl.text.trim(),
      paperWidth: _paperWidth,
      restaurantName: _nameCtl.text.trim(),
      autoPrintKitchen: _autoKitchen,
    ));
  }

  Order _dummyOrder() => Order(
    id: 'test', tableNumber: 1, tableName: 'Table 1',
    items: [], trackingCode: 'TEST',
  );

  Widget _label(String text, ColorScheme cs) => Text(
    text,
    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: cs.onSurfaceVariant),
  );

  Widget _field(TextEditingController ctl, IconData icon, String hint) {
    return TextField(
      controller: ctl,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20),
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
