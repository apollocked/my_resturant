import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/widgets/order/order_detail_action_button.dart';
import 'package:my_resturant/presentation/widgets/order/order_detail_foods_header.dart';
import 'package:my_resturant/presentation/widgets/order/order_detail_header.dart';
import 'package:my_resturant/presentation/widgets/order/order_detail_item_card.dart';
import 'package:my_resturant/presentation/widgets/order/order_detail_notes.dart';
import 'package:my_resturant/presentation/widgets/order/order_detail_timeline.dart';
import 'package:my_resturant/presentation/widgets/order/order_status_style.dart';
import 'package:my_resturant/shared/confirm_dialog.dart';

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
    final hasNext = order.status != OrderStatus.served;
    final nextLabel = order.status == OrderStatus.pending
        ? t('next_prepare')
        : t('next_serve');
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
            onRemove: canEdit ? () => _removeItem(context, entry.key) : null,
            onQuantityChanged: canEdit
                ? (qty) => _changeQty(context, entry.key, qty)
                : null,
          ),
        ),
        if (order.notes.isNotEmpty || canEdit)
          OrderDetailNotes(
            notes: order.notes,
            cs: cs,
            canEdit: canEdit,
            onEdit: canEdit ? (n) => _editNotes(context, n) : null,
          ),
        if (canEdit) ...[
          SizedBox(height: isDesktop ? 40 : 32),
          OrderDetailActionButton(
            hasNext: hasNext,
            color: color,
            nextLabel: nextLabel,
            t: t,
            isDesktop: isDesktop,
            onNext: () => _next(context),
            onReset: () => _reset(context),
          ),
        ],
      ],
    );
  }

  Future<void> _removeItem(BuildContext context, int index) async {
    final confirmed = await showConfirmDialog(
      context,
      title: t('delete'),
      message: t('confirm_delete_item'),
      confirmLabel: t('delete'),
      cancelLabel: t('cancel'),
    );
    if (!confirmed || !context.mounted) return;
    await cubit.removeItemFromOrder(order.id, index);
    if (!context.mounted) return;
    context.pop();
  }

  void _changeQty(BuildContext context, int index, int qty) {
    cubit.updateItemQuantity(order.id, index, qty);
  }

  void _editNotes(BuildContext context, String notes) {
    cubit.updateOrderNotes(order.id, notes);
  }

  Future<void> _next(BuildContext context) async {
    await cubit.updateOrderStatus(
      order.id,
      OrderStatusStyle.next(order.status),
    );
    if (context.mounted) context.pop();
  }

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: t('again'),
      message: t('again_confirm_served'),
      confirmLabel: t('again'),
      cancelLabel: t('cancel'),
    );
    if (!confirmed || !context.mounted) return;
    await cubit.updateOrderStatus(order.id, OrderStatus.pending);
    if (context.mounted) context.pop();
  }
}
