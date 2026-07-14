import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/order/order_card.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});
  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final orders = context.watch<OrderCubit>().state.orders;
    final cubit = context.read<OrderCubit>();
    final activeOrders = orders.where((o) => o.status != OrderStatus.served).toList();
    final servedOrders = orders.where((o) => o.status == OrderStatus.served).toList();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t('kitchen_title'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: cs.onSurface)),
          const SizedBox(height: 2),
          Text(t('orders_count').replaceAll('{count}', '${orders.length}'),
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _pill('${t('active')} ${activeOrders.length}', 0, cs),
            const SizedBox(width: 4),
            _pill('${t('served')} ${servedOrders.length}', 1, cs),
          ]),
        ),
      ])),
      const SizedBox(height: 16),
      Expanded(child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _tabIndex == 0
            ? _orderList(activeOrders, cubit, context, t)
            : _orderList(servedOrders, cubit, context, t),
      )),
    ])));
  }

  Widget _pill(String label, int index, ColorScheme cs) {
    final sel = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: sel ? Colors.white : cs.onSurfaceVariant)),
      ),
    );
  }

  Widget _orderList(List<Order> orders, OrderCubit cubit, BuildContext context, String Function(String) t) {
    final cs = Theme.of(context).colorScheme;
    if (orders.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 100, height: 100, decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
          child: Icon(Icons.receipt_long_outlined, size: 44, color: cs.onSurfaceVariant)),
        const SizedBox(height: 20),
        Text(t('kitchen_empty'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
      ]));
    }
    return ListView.builder(
      key: ValueKey(_tabIndex),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final o = orders[index];
        final hasNext = OrderCard.nextStatus.containsKey(o.status);
        return GestureDetector(
          onTap: () => context.push('/order-detail', extra: o),
          child: OrderCard(order: o, showTimeline: true,
            onNextStatus: hasNext ? () => cubit.updateOrderStatus(o.id, OrderCard.nextStatus[o.status]!) : null,
            onReset: !hasNext ? () => cubit.updateOrderStatus(o.id, OrderStatus.pending) : null),
        );
      },
    );
  }
}
