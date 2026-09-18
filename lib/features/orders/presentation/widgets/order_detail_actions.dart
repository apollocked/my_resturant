import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_status_style.dart';
import 'package:my_resturant/shared/confirm_dialog.dart';

/// Confirm-and-apply actions for the order detail screen, kept separate from
/// the widget tree so each file stays small.
class OrderDetailActions {
  OrderDetailActions({
    required this.order,
    required this.cubit,
    required this.t,
  });

  final Order order;
  final OrderCubit cubit;
  final String Function(String) t;

  Future<void> removeItem(BuildContext context, int index) async {
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

  void changeQuantity(BuildContext context, int index, int qty) {
    cubit.updateItemQuantity(order.id, index, qty);
  }

  void editNotes(BuildContext context, String notes) {
    cubit.updateOrderNotes(order.id, notes);
  }

  Future<void> next(BuildContext context) async {
    await cubit.updateOrderStatus(order.id, OrderStatusStyle.next(order.status));
    if (context.mounted) context.pop();
  }

  Future<void> reset(BuildContext context) async {
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

  Future<void> cancel(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: t('cancel_order'),
      message: t('cancel_order_confirm'),
      confirmLabel: t('cancel_order'),
      cancelLabel: t('cancel'),
    );
    if (!confirmed || !context.mounted) return;
    await cubit.updateOrderStatus(order.id, OrderStatus.cancelled);
    if (context.mounted) context.pop();
  }
}