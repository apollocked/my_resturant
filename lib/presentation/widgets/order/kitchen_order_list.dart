import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/widgets/order/order_card.dart';
import 'package:my_resturant/presentation/widgets/shared/shimmer_skeletons.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';
import 'package:my_resturant/presentation/widgets/shared/empty_state.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class KitchenOrderList extends StatelessWidget {
  final List<Order> orders;
  final OrderCubit cubit;
  final String Function(String) t;
  final bool canEdit;
  final String tabKey;
  const KitchenOrderList({super.key, required this.orders, required this.cubit, required this.t, required this.canEdit, required this.tabKey});

  @override
  Widget build(BuildContext context) {
    final isDesktop = R.isDesktop(context);
    if (orders.isEmpty) {
      if (context.read<OrderCubit>().state.isLoading) {
        return isDesktop
            ? GridView(padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.0, crossAxisSpacing: R.gridSpacing(context), mainAxisSpacing: R.gridSpacing(context)),
                children: List.generate(4, (_) => const ShimmerOrderCard()))
            : ShimmerListView(itemCount: 4, itemBuilder: () => const ShimmerOrderCard());
      }
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: t('kitchen_empty'),
        subtitle: t('kitchen_empty_subtitle'),
      );
    }
    final widgets = orders.map((o) {
      final hasNext = OrderCard.nextStatus.containsKey(o.status);
      return PressableScale(
        onTap: () => context.push('/order-detail', extra: o),
        child: OrderCard(order: o, showTimeline: true,
          onNextStatus: canEdit && hasNext ? () => cubit.updateOrderStatus(o.id, OrderCard.nextStatus[o.status]!) : null,
          onReset: canEdit && !hasNext ? () => cubit.updateOrderStatus(o.id, OrderStatus.pending) : null),
      );
    }).toList();
    return RefreshIndicator(
      onRefresh: () async => context.read<OrderCubit>().refresh(),
      child: isDesktop
          ? GridView(key: ValueKey('grid_$tabKey'), padding: EdgeInsets.fromLTRB(R.padding(context), 0, R.padding(context), 100),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.0, crossAxisSpacing: R.gridSpacing(context), mainAxisSpacing: R.gridSpacing(context)),
              children: widgets)
          : ListView(key: ValueKey('list_$tabKey'), padding: EdgeInsets.fromLTRB(R.padding(context), 0, R.padding(context), 100), children: widgets),
    );
  }
}
