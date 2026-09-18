import 'package:flutter/material.dart';

import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/features/orders/presentation/widgets/cleaning_request_bar.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_card.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_status_style.dart';
import 'package:my_resturant/shared/confirm_dialog.dart';
import 'package:my_resturant/shared/pressable_scale.dart';
import 'package:go_router/go_router.dart';

/// One served / pending order row: the tappable [OrderCard] plus, on waiter
/// devices, the table cleaning request bar underneath.
class KitchenOrderTile extends StatelessWidget {
  final Order order;
  final OrderCubit cubit;
  final String Function(String) t;
  final bool canEdit;
  final bool cleaningRequested;
  final VoidCallback onRequestCleaning;

  const KitchenOrderTile({
    super.key,
    required this.order,
    required this.cubit,
    required this.t,
    required this.canEdit,
    required this.cleaningRequested,
    required this.onRequestCleaning,
  });

  @override
  Widget build(BuildContext context) {
    final o = order;
    final hasNext = o.status != OrderStatus.served && o.status != OrderStatus.cancelled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PressableScale(
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
        if (o.status == OrderStatus.served && !canEdit) ...[
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: R.cardPadding(context)),
            child: CleaningRequestBar(
              n: o.tableNumber,
              requested: cleaningRequested,
              t: t,
              cs: Theme.of(context).colorScheme,
              onRequest: onRequestCleaning,
            ),
          ),
        ],
      ],
    );
  }
}