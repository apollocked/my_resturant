import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/printer_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/order/add_order_items_sheet.dart';
import 'package:my_resturant/presentation/widgets/order/order_detail_body.dart';
import 'package:my_resturant/presentation/widgets/order/order_status_style.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;
  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final color = OrderStatusStyle.color(order.status);
    final cubit = context.read<OrderCubit>();
    final role = context.watch<RoleCubit>().state.role;
    final canEdit = role != Role.waiter;
    final canPlaceItems = role != Role.kitchen;
    final isDesktop = R.isDesktop(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${order.displayTable} — ${order.displayTrackingCode}'),
        actions: [
          IconButton(
            onPressed: () => _showPrintDialog(context, t),
            icon: const Icon(Icons.print, size: 22),
            tooltip: t('print_receipt'),
          ),
        ],
      ),
      floatingActionButton: canPlaceItems
          ? FloatingActionButton.extended(
              onPressed: () => _addItems(context),
              backgroundColor: AppColors.primary,
              foregroundColor: cs.onPrimary,
              icon: const Icon(Icons.add_shopping_cart, size: 20),
              label: Text(
                t('add_items'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: R.isPhone(context) ? 100 : 40,
            left: R.padding(context),
            right: R.padding(context),
            top: R.padding(context),
          ),
          child: OrderDetailBody(
            order: order,
            color: color,
            cs: cs,
            t: t,
            cubit: cubit,
            locale: settings.locale,
            canEdit: canEdit,
            isDesktop: isDesktop,
          ),
        ),
      ),
    );
  }

  void _showPrintDialog(BuildContext context, String Function(String) t) {
    final printer = context.read<PrinterCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('print_receipt')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(t('print_receipt')),
              subtitle: const Text('Full receipt with prices'),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await printer.printReceipt(order);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Printed' : 'Print failed')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: Text(t('kitchen_ticket') ?? 'Kitchen Ticket'),
              subtitle: const Text('Items only, no prices'),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await printer.printKitchen(order);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Printed' : 'Print failed')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addItems(BuildContext context) async {
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
}
