import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/widgets/order/order_card.dart';
import 'package:my_resturant/presentation/widgets/order/order_status_style.dart';
import 'package:my_resturant/shared/shimmer_skeletons.dart';
import 'package:my_resturant/shared/staggered_grid.dart';
import 'package:my_resturant/shared/pressable_scale.dart';
import 'package:my_resturant/shared/empty_state.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/shared/confirm_dialog.dart';

class KitchenOrderList extends StatelessWidget {
  final List<Order> orders;
  final OrderCubit cubit;
  final String Function(String) t;
  final bool canEdit;
  final String tabKey;
  const KitchenOrderList({
    super.key,
    required this.orders,
    required this.cubit,
    required this.t,
    required this.canEdit,
    required this.tabKey,
  });

  @override
  Widget build(BuildContext context) {
    final isGrid = !R.isPhone(context);
    if (orders.isEmpty) {
      if (context.read<OrderCubit>().state.isLoading) {
        return isGrid
            ? GridView(
                padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 520,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: R.gridSpacing(context),
                  mainAxisSpacing: R.gridSpacing(context),
                ),
                children: List.generate(4, (_) => const ShimmerOrderCard()),
              )
            : ShimmerListView(
                itemCount: 4,
                itemBuilder: () => const ShimmerOrderCard(),
              );
      }
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: t('kitchen_empty'),
        subtitle: t('kitchen_empty_subtitle'),
      );
    }
    final widgets = orders.map((o) {
      final hasNext =
          o.status != OrderStatus.served && o.status != OrderStatus.cancelled;
      return StaggeredEntrance(
        child: PressableScale(
          onTap: () => context.push('/order-detail', extra: o),
          child: OrderCard(
          order: o,
          showTimeline: true,
          onNextStatus: canEdit && hasNext
              ? () => cubit.updateOrderStatus(
                  o.id,
                  OrderStatusStyle.next(o.status),
                )
              : null,
          onCancel: canEdit && hasNext
              ? () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: t('cancel_order'),
                    message: t('cancel_order_confirm'),
                    confirmLabel: t('cancel_order'),
                    cancelLabel: t('cancel'),
                  );
                  if (confirmed) {
                    cubit.updateOrderStatus(o.id, OrderStatus.cancelled);
                  }
                }
              : null,
          onReset: canEdit && !hasNext
              ? () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: t('again'),
                    message: t('again_confirm_served'),
                    confirmLabel: t('again'),
                    cancelLabel: t('cancel'),
                  );
                  if (confirmed) {
                    cubit.updateOrderStatus(o.id, OrderStatus.pending);
                  }
                }
              : null,
        ),
      ),
      );
    }).toList();
    return RefreshIndicator(
      onRefresh: () async => context.read<OrderCubit>().refresh(),
      child: isGrid
          ? SingleChildScrollView(
              key: ValueKey('grid_$tabKey'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                R.padding(context),
                0,
                R.padding(context),
                100,
              ),
              child: Wrap(
                spacing: R.gridSpacing(context),
                runSpacing: R.gridSpacing(context),
                children: [
                  for (final w in widgets)
                    SizedBox(width: R.orderCardWidth(context), child: w),
                ],
              ),
            )
          : ListView(
              key: ValueKey('list_$tabKey'),
              padding: EdgeInsets.fromLTRB(
                R.padding(context),
                0,
                R.padding(context),
                100,
              ),
              children: widgets,
            ),
    );
  }
}
