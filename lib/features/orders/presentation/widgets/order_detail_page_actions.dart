import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/features/orders/domain/entities/cart_item.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/features/printer/presentation/cubits/printer_cubit.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/features/orders/presentation/widgets/add_order_items_sheet.dart';

Future<void> showPrintDialog(
  BuildContext context,
  Order order,
  String Function(String) t,
) async {
  final printer = context.read<PrinterCubit>();
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t('print_receipt')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text(t('print_receipt')),
            subtitle: Text(t('full_receipt')),
            onTap: () async {
              Navigator.pop(ctx);
              final locale = context.read<SettingsCubit>().state.locale;
              final ok = await printer.printReceipt(order, locale);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ok ? t('printed') : t('print_failed'))),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: Text(t('kitchen_ticket')),
            subtitle: Text(t('items_only')),
            onTap: () async {
              Navigator.pop(ctx);
              final locale = context.read<SettingsCubit>().state.locale;
              final ok = await printer.printKitchen(order, locale);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ok ? t('printed') : t('print_failed'))),
              );
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> showAddOrderItemsSheet(
  BuildContext context,
  Order order,
) async {
  final settings = context.read<SettingsCubit>().state;
  String t(String key) => Tr.get(key, settings.locale);
  final state = context.read<OrderCubit>().state;
  final items = await showModalBottomSheet<List<CartItem>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddOrderItemsSheet(recipes: state.recipes),
  );
  if (!context.mounted || items == null || items.isEmpty) return;
  final cubit = context.read<OrderCubit>();
  try {
    await cubit.addItemsToOrder(order.id, items);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t('items_added'))));
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t('error_occurred'))));
  }
}