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
    final orderState = context.watch<OrderCubit>().state;
    final now = DateTime.now();
    final todayOrders = orderState.orders.where((o) => o.createdAt.year == now.year && o.createdAt.month == now.month && o.createdAt.day == now.day).toList();
    final cubit = context.read<OrderCubit>();
    final activeOrders = todayOrders.where((o) => o.status != OrderStatus.served).toList();
    final servedOrders = todayOrders.where((o) => o.status == OrderStatus.served).toList();
    final servedTableNums = <int>{};
    for (final o in servedOrders) {
      servedTableNums.add(o.tableNumber);
    }
    final clearedToday = servedTableNums.where((n) => orderState.clearedTables.contains(n)).toSet();
    final needCleaning = servedTableNums.difference(clearedToday).toList()..sort();
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);

    return Scaffold(body: SafeArea(child: Column(children: [
      Padding(padding: EdgeInsets.fromLTRB(R.padding(context), 16, R.padding(context), 0), child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t('kitchen_title'), style: TextStyle(fontSize: R.fontXl(context), fontWeight: FontWeight.w800, color: cs.onSurface)),
          const SizedBox(height: 2),
          Text(t('orders_count').replaceAll('{count}', '${todayOrders.length}'),
              style: TextStyle(fontSize: R.fontSm(context), color: cs.onSurfaceVariant)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _pill('${t('active')} ${activeOrders.length}', 0, cs, isDesktop),
            const SizedBox(width: 4),
            _pill('${t('served')} ${servedOrders.length}', 1, cs, isDesktop),
            const SizedBox(width: 4),
            _pill('${t('cleared')} ${needCleaning.length}', 2, cs, isDesktop),
          ]),
        ),
      ])),
      const SizedBox(height: 16),
      Expanded(child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _tabIndex == 0
            ? _orderList(activeOrders, cubit, context, t, canEdit)
            : _tabIndex == 1
                ? _orderList(servedOrders, cubit, context, t, canEdit)
                : _cleanList(needCleaning, cubit, context, t, cs),
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
    final isDesktop = R.isDesktop(context);
    final cs = Theme.of(context).colorScheme;
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

  Widget _cleanList(List<int> tableList, OrderCubit cubit, BuildContext context, String Function(String) t, ColorScheme cs) {
    final orderState = cubit.state;
    if (tableList.isEmpty) {
      final isDesktop = R.isDesktop(context);
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: R.hp(context, isDesktop ? 18 : 22), height: R.hp(context, isDesktop ? 18 : 22),
          decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
          child: Icon(Icons.cleaning_services, size: isDesktop ? 64 : R.isTablet(context) ? 52 : 44, color: cs.onSurfaceVariant)),
        const SizedBox(height: 20),
        Text(t('no_cleared_tables'), style: TextStyle(fontSize: R.fontLg(context), fontWeight: FontWeight.w600, color: cs.onSurface)),
      ]));
    }
    return RefreshIndicator(
      onRefresh: () async => cubit.refresh(),
      child: ListView.builder(
        key: ValueKey('clean_$_tabIndex'),
        padding: EdgeInsets.symmetric(horizontal: R.padding(context), vertical: 8),
        itemCount: tableList.length,
        itemBuilder: (context, index) {
          final n = tableList[index];
          final tableName = orderState.getTableName(n);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.cleaning_services, color: Colors.green, size: 22),
              ),
              title: Text('${t('table')} $n${tableName != '${t('table')} $n' ? ' — $tableName' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              subtitle: Text(t('clear_table'), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
              trailing: FilledButton.icon(
                icon: const Icon(Icons.check, size: 18),
                label: Text(t('clear_table'), style: const TextStyle(fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () => cubit.clearTable(n),
              ),
            ),
          );
        },
      ),
    );
  }
}
