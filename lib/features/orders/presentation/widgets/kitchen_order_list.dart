import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/features/orders/presentation/widgets/kitchen_order_loading.dart';
import 'package:my_resturant/features/orders/presentation/widgets/kitchen_order_tile.dart';
import 'package:my_resturant/shared/animated_item_list.dart';
import 'package:my_resturant/shared/empty_state.dart';
import 'package:my_resturant/shared/haptics.dart';

/// The kitchen / waiter order feed: a stable animated list of order tiles
/// keyed by id so rows keep their layout while statuses stream in.
class KitchenOrderList extends StatefulWidget {
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
  State<KitchenOrderList> createState() => _KitchenOrderListState();
}

class _KitchenOrderListState extends State<KitchenOrderList> {
  final Map<String, Order> _ordersById = {};

  @override
  void initState() {
    super.initState();
    for (final o in widget.orders) {
      _ordersById[o.id] = o;
    }
  }

  @override
  void didUpdateWidget(covariant KitchenOrderList old) {
    super.didUpdateWidget(old);
    for (final o in widget.orders) {
      _ordersById[o.id] = o;
    }
  }

  Widget _buildItem(BuildContext context, Object id) {
    final o = _ordersById[id as String];
    if (o == null) return const SizedBox.shrink();
    return KitchenOrderTile(
      order: o,
      cubit: widget.cubit,
      t: widget.t,
      canEdit: widget.canEdit,
      cleaningRequested: widget.cubit.state.cleaningRequests
          .containsKey(o.tableNumber),
      onRequestCleaning: () {
        Haptics.added();
        widget.cubit.requestCleaning(o.tableNumber);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                widget.t('cleaning_request_sent').replaceAll(
                  '{table}',
                  '${o.tableNumber}',
                ),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final isGrid = !R.isPhone(context);
    if (widget.orders.isEmpty) {
      if (context.read<OrderCubit>().state.isLoading) {
        return KitchenOrderLoading(isGrid: isGrid);
      }
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: t('kitchen_empty'),
        subtitle: t('kitchen_empty_subtitle'),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context.read<OrderCubit>().refresh(),
      child: AnimatedItemList(
        ids: widget.orders.map((o) => o.id).toList(),
        itemBuilder: _buildItem,
        isGrid: isGrid,
        itemWidth: R.orderCardWidth(context),
        spacing: R.gridSpacing(context),
        padding: EdgeInsets.fromLTRB(
          R.padding(context),
          0,
          R.padding(context),
          100,
        ),
        physics: isGrid ? const AlwaysScrollableScrollPhysics() : null,
      ),
    );
  }
}