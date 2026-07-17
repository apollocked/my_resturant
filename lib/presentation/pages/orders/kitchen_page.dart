import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/order/order_card.dart';
import 'package:my_resturant/presentation/widgets/shared/shimmer_skeletons.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

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
    final role = context.watch<RoleCubit>().state.role;
    final canEdit = role != Role.waiter;
    String t(String key) => Tr.get(key, settings.locale);
    final orders = context.watch<OrderCubit>().state.orders;
    final cubit = context.read<OrderCubit>();
    final activeOrders = orders.where((o) => o.status != OrderStatus.served).toList();
    final servedOrders = orders.where((o) => o.status == OrderStatus.served).toList();
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);

    return Scaffold(body: SafeArea(child: Column(children: [
      Padding(padding: EdgeInsets.fromLTRB(R.padding(context), 16, R.padding(context), 0), child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t('kitchen_title'), style: TextStyle(fontSize: R.fontXl(context), fontWeight: FontWeight.w800, color: cs.onSurface)),
          const SizedBox(height: 2),
          Text(t('orders_count').replaceAll('{count}', '${orders.length}'),
              style: TextStyle(fontSize: R.fontSm(context), color: cs.onSurfaceVariant)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _pill('${t('active')} ${activeOrders.length}', 0, cs, isDesktop),
            const SizedBox(width: 4),
            _pill('${t('served')} ${servedOrders.length}', 1, cs, isDesktop),
          ]),
        ),
      ])),
      const SizedBox(height: 16),
      Expanded(child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _tabIndex == 0
            ? _orderList(activeOrders, cubit, context, t, canEdit)
            : _orderList(servedOrders, cubit, context, t, canEdit),
      )),
    ])));
  }

  Widget _pill(String label, int index, ColorScheme cs, bool isDesktop) {
    final sel = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 20 : 14, vertical: isDesktop ? 10 : 7),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(
          fontSize: isDesktop ? 14 : 12, fontWeight: FontWeight.w700,
          color: sel ? cs.onPrimary : cs.onSurfaceVariant)),
      ),
    );
  }

  Widget _orderList(List<Order> orders, OrderCubit cubit, BuildContext context, String Function(String) t, bool canEdit) {
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);
    final orderState = cubit.state;
    final servedTables = <int, List<Order>>{};
    if (_tabIndex == 1) {
      for (final o in orders) {
        servedTables.putIfAbsent(o.tableNumber, () => []).add(o);
      }
    }
    final clearableTables = servedTables.keys.where((n) => !orderState.clearedTables.contains(n)).toList();
    if (orders.isEmpty) {
      if (context.read<OrderCubit>().state.isLoading) {
        return isDesktop
            ? GridView(padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.0,
                  crossAxisSpacing: R.gridSpacing(context), mainAxisSpacing: R.gridSpacing(context)),
                children: List.generate(4, (_) => const ShimmerOrderCard()))
            : ShimmerListView(itemCount: 4, itemBuilder: () => const ShimmerOrderCard());
      }
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: R.hp(context, isDesktop ? 18 : 22), height: R.hp(context, isDesktop ? 18 : 22),
          decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
          child: Icon(Icons.receipt_long_outlined, size: isDesktop ? 64 : R.isTablet(context) ? 52 : 44, color: cs.onSurfaceVariant)),
        const SizedBox(height: 20),
        Text(t('kitchen_empty'), style: TextStyle(fontSize: R.fontLg(context), fontWeight: FontWeight.w600, color: cs.onSurface)),
      ]));
    }
    final orderWidgets = orders.map((o) {
      final hasNext = OrderCard.nextStatus.containsKey(o.status);
      return GestureDetector(
        onTap: () => context.push('/order-detail', extra: o),
        child: OrderCard(order: o, showTimeline: true,
          onNextStatus: canEdit && hasNext ? () => cubit.updateOrderStatus(o.id, OrderCard.nextStatus[o.status]!) : null,
          onReset: canEdit && !hasNext ? () => cubit.updateOrderStatus(o.id, OrderStatus.pending) : null),
      );
    }).toList();
    if (_tabIndex == 0) {
      return RefreshIndicator(
        onRefresh: () async => context.read<OrderCubit>().refresh(),
        child: isDesktop
            ? GridView(key: ValueKey('grid_$_tabIndex'), padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.0,
                  crossAxisSpacing: R.gridSpacing(context), mainAxisSpacing: R.gridSpacing(context)),
                children: orderWidgets)
            : ListView(key: ValueKey('list_$_tabIndex'), padding: EdgeInsets.symmetric(horizontal: R.padding(context)), children: orderWidgets),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context.read<OrderCubit>().refresh(),
      child: ListView(
        key: ValueKey('list_$_tabIndex'),
        padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
        children: [
          if (clearableTables.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(t('clear_table_section'), style: TextStyle(fontSize: R.fontMd(context), fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: clearableTables.map((n) => ActionChip(
                avatar: const Icon(Icons.cleaning_services, size: 18, color: Colors.green),
                label: Text('${t('clear_table')} $n', style: const TextStyle(fontWeight: FontWeight.w600)),
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                side: BorderSide(color: Colors.green.withValues(alpha: 0.3)),
                onPressed: () => cubit.clearTable(n),
              )).toList(),
            ),
            const SizedBox(height: 12),
          ],
          ...orderWidgets,
        ],
      ),
    );
  }
}
