import 'package:flutter/material.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_detail_action_button.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_detail_actions.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_detail_foods_header.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_detail_header.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_detail_item_card.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_detail_notes.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_detail_timeline.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_status_style.dart';

class OrderDetailBody extends StatelessWidget {
  const OrderDetailBody({
    super.key,
    required this.order,
    required this.color,
    required this.cs,
    required this.t,
    required this.cubit,
    required this.locale,
    required this.canEdit,
    this.isDesktop = false,
  });

  final Order order;
  final Color color;
  final ColorScheme cs;
  final String Function(String) t;
  final OrderCubit cubit;
  final Locale locale;
  final bool canEdit;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final actions = OrderDetailActions(order: order, cubit: cubit, t: t);
    final isActive = order.status != OrderStatus.served &&
        order.status != OrderStatus.cancelled;
    final nextLabel =
        order.status == OrderStatus.pending ? t('next_prepare') : t('next_serve');
    final time =
        '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        OrderDetailHeader(
          color: color,
          statusLabel: OrderStatusStyle.label(order.status, locale),
          total: order.totalPrice,
          t: t,
          isDesktop: isDesktop,
        ),
        SizedBox(height: isDesktop ? 28 : 20),
        OrderDetailTimeline(
          current: order.status,
          t: t,
          cs: cs,
          isDesktop: isDesktop,
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        OrderDetailFoodsHeader(
          time: time,
          title: t('foods'),
          cs: cs,
          isDesktop: isDesktop,
        ),
        const SizedBox(height: 12),
        ...order.items.asMap().entries.map(
          (entry) => OrderDetailItemCard(
            item: entry.value,
            t: t,
            cs: cs,
            isDesktop: isDesktop,
            canEdit: canEdit,
            onRemove: canEdit ? () => actions.removeItem(context, entry.key) : null,
            onQuantityChanged:
                canEdit ? (qty) => actions.changeQuantity(context, entry.key, qty) : null,
          ),
        ),
        if (order.notes.isNotEmpty || canEdit)
          OrderDetailNotes(
            notes: order.notes,
            cs: cs,
            t: t,
            canEdit: canEdit,
            onEdit: canEdit ? (n) => actions.editNotes(context, n) : null,
          ),
        if (canEdit) ...[
          SizedBox(height: isDesktop ? 40 : 32),
          OrderDetailActionButton(
            hasNext: isActive,
            color: color,
            nextLabel: nextLabel,
            t: t,
            isDesktop: isDesktop,
            onNext: () => actions.next(context),
            onReset: () => actions.reset(context),
            onCancel: isActive ? () => actions.cancel(context) : null,
          ),
        ],
      ],
    );
  }
}