import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/theme/app_theme.dart';
import 'package:my_resturant/models/order_model.dart';
import 'package:my_resturant/cubits/order_cubit.dart';
import 'package:my_resturant/cubits/settings_cubit.dart';
import 'package:my_resturant/l10n/tr.dart';
import 'package:my_resturant/widgets/order_card.dart';

class KitchenPage extends StatelessWidget {
  const KitchenPage({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final orders = context.watch<OrderCubit>().state.orders;
    final cubit = context.read<OrderCubit>();
    return Scaffold(body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      const SizedBox(height: 16),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
        const Spacer(),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(t('orders_count').replaceAll('{count}', '${orders.length}'), style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        Text(t('kitchen_title'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
      ])),
      const SizedBox(height: 16),
      if (orders.isEmpty)
        Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 100, height: 100, decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_outlined, size: 44, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          Text(t('kitchen_empty'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ])))
      else
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: orders.length,
          itemBuilder: (context, index) {
            final o = orders[index];
            final hasNext = OrderCard.nextStatus.containsKey(o.status);
            return GestureDetector(
              onTap: () => context.push('/order-detail', extra: o),
              child: OrderCard(order: o, showTimeline: true,
                onNextStatus: hasNext ? () => cubit.updateOrderStatus(o.id, OrderCard.nextStatus[o.status]!) : null,
                onReset: !hasNext ? () => cubit.updateOrderStatus(o.id, OrderStatus.pending) : null));
          },
        )),
    ])));
  }
}
