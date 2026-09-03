import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/widgets/order/history_order_tile.dart';
import 'package:my_resturant/shared/empty_state.dart';
import 'package:my_resturant/shared/staggered_grid.dart';

class HistoryOrderList extends StatelessWidget {
  final List<Order> orders;
  final String Function(String) t;
  const HistoryOrderList({super.key, required this.orders, required this.t});

  @override
  Widget build(BuildContext context) {
    final p = R.padding(context);
    if (orders.isEmpty) {
      return EmptyState(
        icon: Icons.history,
        title: t('history_empty'),
        subtitle: t('history_empty_subtitle'),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context.read<OrderCubit>().refresh(),
      child: StaggeredGrid(
        itemCount: orders.length,
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: EdgeInsets.fromLTRB(p, 0, p, 100),
        physics: const AlwaysScrollableScrollPhysics(),
        builder: (ctx, i) => HistoryOrderTile(order: orders[i], t: t),
      ),
    );
  }
}
