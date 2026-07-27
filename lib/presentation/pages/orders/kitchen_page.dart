import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/order/kitchen_header.dart';
import 'package:my_resturant/presentation/widgets/order/kitchen_order_list.dart';
import 'package:my_resturant/presentation/widgets/order/kitchen_clean_list.dart';

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
    final todayOrders = orderState.orders.where((o) =>
        o.createdAt.year == now.year && o.createdAt.month == now.month && o.createdAt.day == now.day).toList();
    final cubit = context.read<OrderCubit>();
    final activeOrders = todayOrders.where((o) => o.status != OrderStatus.served).toList();
    final servedOrders = todayOrders.where((o) => o.status == OrderStatus.served).toList();
    final servedTableNums = <int>{}..addAll(servedOrders.map((o) => o.tableNumber));
    final clearedToday = servedTableNums.where((n) => orderState.clearedTables.contains(n)).toSet();
    final needCleaning = servedTableNums.difference(clearedToday).toList()..sort();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(body: Column(children: [
      KitchenHeader(
        title: t('kitchen_title'),
        countLabel: t('orders_count').replaceAll('{count}', '${todayOrders.length}'),
        selectedIndex: _tabIndex,
        tabLabels: ['${t('active')} ${activeOrders.length}', '${t('served')} ${servedOrders.length}', '${t('cleared')} ${needCleaning.length}'],
        onTabChanged: (i) => setState(() => _tabIndex = i),
      ),
      const SizedBox(height: 16),
      Expanded(child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _tabIndex == 0
            ? KitchenOrderList(orders: activeOrders, cubit: cubit, t: t, canEdit: canEdit, tabKey: 'active')
            : _tabIndex == 1
                ? KitchenOrderList(orders: servedOrders, cubit: cubit, t: t, canEdit: canEdit, tabKey: 'served')
                : KitchenCleanList(tableList: needCleaning, cubit: cubit, t: t, cs: cs),
      )),
    ]));
  }
}
