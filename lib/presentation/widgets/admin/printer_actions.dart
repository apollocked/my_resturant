import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/services/printer_config.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/printer_cubit.dart';

class PrinterActions extends StatelessWidget {
  const PrinterActions({super.key, required this.config, required this.t});
  final PrinterConfig config;
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final printer = context.watch<PrinterCubit>();
    final connected = printer.state.isConnected;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () async {
              await _save(printer);
              connected ? printer.disconnect() : printer.connect();
            },
            icon: Icon(connected ? Icons.link_off : Icons.link, size: 20),
            label: Text(connected ? 'Disconnect' : 'Connect'),
            style: FilledButton.styleFrom(
              backgroundColor: connected ? cs.error : cs.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: connected
                ? () async {
                    await _save(printer);
                    final ok = await printer.printReceipt(_dummyOrder());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? 'Test printed' : 'Print failed')),
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.print, size: 20),
            label: Text(t('print_test')),
          ),
        ),
      ],
    );
  }

  Future<void> _save(PrinterCubit cubit) async => cubit.updateConfig(config);

  Order _dummyOrder() => Order(
    id: 'test', tableNumber: 1, tableName: 'Table 1',
    items: [], trackingCode: 'TEST',
  );
}

Widget label(String text, ColorScheme cs) => Text(
  text,
  style: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
    color: cs.onSurfaceVariant,
  ),
);

Widget field(TextEditingController ctl, IconData icon, String hint) {
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
