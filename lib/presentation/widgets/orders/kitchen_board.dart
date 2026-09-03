import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/widgets/orders/kitchen_clean_list.dart';
import 'package:my_resturant/presentation/widgets/orders/kitchen_order_list.dart';
import 'package:my_resturant/presentation/widgets/orders/kitchen_board_pane.dart';

class KitchenBoard extends StatelessWidget {
  final ColorScheme cs;
  final String Function(String) t;
  final List<Order> activeOrders;
  final List<Order> servedOrders;
  final List<int> needCleaning;
  final bool canEdit;
  final bool isWaiter;
  final OrderCubit cubit;
  final String boardTitle;
  const KitchenBoard({
    super.key,
    required this.cs,
    required this.t,
    required this.activeOrders,
    required this.servedOrders,
    required this.needCleaning,
    required this.canEdit,
    required this.isWaiter,
    required this.cubit,
    required this.boardTitle,
  });

  @override
  Widget build(BuildContext context) {
    final panes = <KitchenBoardPane>[
      KitchenBoardPane(
        title: '${t('active')} (${activeOrders.length})',
        icon: Icons.local_fire_department,
        color: AppColors.primary,
        child: KitchenOrderList(
          orders: activeOrders,
          cubit: cubit,
          t: t,
          canEdit: canEdit,
          tabKey: 'board_active',
        ),
      ),
      KitchenBoardPane(
        title: '${t('served')} (${servedOrders.length})',
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        child: KitchenOrderList(
          orders: servedOrders,
          cubit: cubit,
          t: t,
          canEdit: canEdit,
          tabKey: 'board_served',
        ),
      ),
      if (!isWaiter)
        KitchenBoardPane(
          title: '${t('cleared')} (${needCleaning.length})',
          icon: Icons.cleaning_services,
          color: AppColors.warning,
          child: KitchenCleanList(
            tableList: needCleaning,
            cubit: cubit,
            t: t,
            cs: cs,
          ),
        ),
    ];
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              R.padding(context),
              16,
              R.padding(context),
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  boardTitle,
                  style: TextStyle(
                    fontSize: R.fontXl(context),
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  '${t('active')} ${activeOrders.length} \u00b7 '
                  '${t('served')} ${servedOrders.length}',
                  style: TextStyle(
                    fontSize: R.fontSm(context),
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => cubit.refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(
                  R.padding(context),
                  0,
                  R.padding(context),
                  100,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < panes.length; i++) ...[
                      if (i > 0)
                        SizedBox(width: R.gridSpacing(context)),
                      SizedBox(
                        width: R.width(context) * 0.42,
                        child: panes[i],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

