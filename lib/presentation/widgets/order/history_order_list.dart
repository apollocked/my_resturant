import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/widgets/order/order_card.dart';
import 'package:my_resturant/presentation/widgets/shared/empty_state.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class HistoryOrderList extends StatelessWidget {
  final List orders;
  final Role? role;
  final String Function(String) t;
  const HistoryOrderList({
    super.key,
    required this.orders,
    required this.role,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = R.isDesktop(context);
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
      child: isDesktop
          ? GridView.builder(
              padding: EdgeInsets.fromLTRB(p, 0, p, 100),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: R.gridSpacing(context),
                mainAxisSpacing: R.gridSpacing(context),
              ),
              itemCount: orders.length,
              itemBuilder: (ctx, i) => _buildCard(ctx, orders[i]),
            )
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(p, 0, p, 100),
              itemCount: orders.length,
              itemBuilder: (ctx, i) => _buildCard(ctx, orders[i]),
            ),
    );
  }

  Widget _buildCard(BuildContext context, dynamic order) {
    return OrderCard(
      order: order,
      showTime: true,
      onReset: role == Role.admin
          ? () {
              final c = context.read<OrderCubit>();
              for (final item in order.items) {
                for (int i = 0; i < item.quantity; i++) {
                  c.addToCart(item.recipe);
                }
              }
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(t('order_restored'))));
              if (context.mounted) context.read<OrderCubit>().refresh();
            }
          : null,
    );
  }
}
