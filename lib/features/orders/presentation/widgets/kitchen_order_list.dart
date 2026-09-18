import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_card.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_status_style.dart';
import 'package:my_resturant/shared/shimmer_skeletons.dart';
import 'package:my_resturant/shared/animated_item_list.dart';
import 'package:my_resturant/shared/pressable_scale.dart';
import 'package:my_resturant/shared/empty_state.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/shared/confirm_dialog.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/haptics.dart';

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
    if (o == null) {
      return const SizedBox.shrink();
    }
    final hasNext =
        o.status != OrderStatus.served && o.status != OrderStatus.cancelled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PressableScale(
          onTap: () => context.push('/order-detail', extra: o),
          child: OrderCard(
            order: o,
            showTimeline: true,
            onNextStatus: widget.canEdit && hasNext
                ? () => widget.cubit.updateOrderStatus(
                      o.id,
                      OrderStatusStyle.next(o.status),
                    )
                : null,
            onCancel: widget.canEdit && hasNext
                ? () async {
                    final confirmed = await showConfirmDialog(
                      context,
                      title: widget.t('cancel_order'),
                      message: widget.t('cancel_order_confirm'),
                      confirmLabel: widget.t('cancel_order'),
                      cancelLabel: widget.t('cancel'),
                    );
                    if (confirmed) {
                      widget.cubit.updateOrderStatus(o.id, OrderStatus.cancelled);
                    }
                  }
                : null,
            onReset: widget.canEdit && !hasNext
                ? () async {
                    final confirmed = await showConfirmDialog(
                      context,
                      title: widget.t('again'),
                      message: widget.t('again_confirm_served'),
                      confirmLabel: widget.t('again'),
                      cancelLabel: widget.t('cancel'),
                    );
                    if (confirmed) {
                      widget.cubit.updateOrderStatus(o.id, OrderStatus.pending);
                    }
                  }
                : null,
          ),
        ),
        if (o.status == OrderStatus.served && !widget.canEdit) ...[
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: R.cardPadding(context)),
            child: _RequestCleaningBar(
              n: o.tableNumber,
              requested: widget.cubit.state.cleaningRequests
                  .containsKey(o.tableNumber),
              t: widget.t,
              cs: Theme.of(context).colorScheme,
              onRequest: () {
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
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final isGrid = !R.isPhone(context);
    if (widget.orders.isEmpty) {
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

/// Waiter-side action for served tables: flags a locked table for cleaning so
/// kitchen staff are notified it is empty, and shows a confirmation once the
/// request has been sent.
class _RequestCleaningBar extends StatelessWidget {
  final int n;
  final bool requested;
  final String Function(String) t;
  final ColorScheme cs;
  final VoidCallback onRequest;
  const _RequestCleaningBar({
    required this.n,
    required this.requested,
    required this.t,
    required this.cs,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.warning;
    if (requested) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 16, color: accent),
            const SizedBox(width: 6),
            Text(
              t('cleaning_requested'),
              style: TextStyle(
                color: accent,
                fontSize: R.fontSm(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
    return PressableScale(
      onTap: onRequest,
      child: SizedBox(
        height: 36,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.cleaning_services, size: 15),
          label: Text(
            t('request_cleaning'),
            style: TextStyle(
              fontSize: R.fontSm(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: BorderSide(color: accent.withValues(alpha: 0.6)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      ),
    );
  }
}