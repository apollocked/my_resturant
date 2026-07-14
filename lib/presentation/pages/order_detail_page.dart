import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/app_image.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;
  const OrderDetailPage({super.key, required this.order});

  static const _colors = {OrderStatus.pending: Colors.orange, OrderStatus.preparing: Colors.blue, OrderStatus.served: AppColors.success};
  static const _nextStatus = {OrderStatus.pending: OrderStatus.preparing, OrderStatus.preparing: OrderStatus.served};

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final color = _colors[order.status]!;
    final hasNext = _nextStatus.containsKey(order.status);
    final cubit = context.read<OrderCubit>();
    final labels = {OrderStatus.pending: t('status_pending'), OrderStatus.preparing: t('status_preparing'), OrderStatus.served: t('status_served')};
    final nextLabel = {OrderStatus.pending: t('next_prepare'), OrderStatus.preparing: t('next_serve')};
    return Scaffold(
      appBar: AppBar(title: Text(order.displayTable)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Text(labels[order.status]!, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13))),
            Text('${order.totalPrice.toInt()} ${t('currency_suffix')}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.primary)),
          ]),
          const SizedBox(height: 20),
          _buildTimeline(order.status, t, cs),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(t('foods'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 12),
          ...order.items.map((item) => _itemCard(item, t)),
          if (order.notes.isNotEmpty)
            Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
              child: Text(order.notes, textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic))),
          const SizedBox(height: 32),
          if (hasNext)
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () { cubit.updateOrderStatus(order.id, _nextStatus[order.status]!); context.pop(); },
              style: FilledButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 14)),
              child: Text(nextLabel[order.status]!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ))
          else
            SizedBox(width: double.infinity, child: OutlinedButton(
              onPressed: () { cubit.updateOrderStatus(order.id, OrderStatus.pending); context.pop(); },
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: Text(t('again'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            )),
        ]),
      ),
    );
  }

  Widget _itemCard(CartItem item, String Function(String) t) {
    return Card(margin: const EdgeInsets.only(bottom: 8),
      child: Padding(padding: const EdgeInsets.all(12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: AppImage(item.recipe.imageUrl, width: 52, height: 52)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text('×${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary))),
            const Spacer(),
            Text(item.recipe.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Text('${item.totalPrice.toInt()} ${t('currency_suffix')}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
            const Spacer(),
            Text('${item.recipe.price.toInt()} ${t('currency_suffix')}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
          if (item.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: Text(item.notes, textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withValues(alpha: 0.7), fontStyle: FontStyle.italic))),
            ]),
          ],
        ])),
      ])));
  }

  Widget _buildTimeline(OrderStatus current, String Function(String) t, ColorScheme cs) {
    return Column(children: [
      Row(children: [
        _dot(OrderStatus.served, current, cs),
        Expanded(child: Container(height: 2, color: current == OrderStatus.served ? _colors[OrderStatus.served] : cs.outlineVariant)),
        _dot(OrderStatus.preparing, current, cs),
        Expanded(child: Container(height: 2, color: current == OrderStatus.preparing || current == OrderStatus.served ? _colors[OrderStatus.preparing] : cs.outlineVariant)),
        _dot(OrderStatus.pending, current, cs),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(t('timeline_served'), style: TextStyle(fontSize: 9, color: current == OrderStatus.served ? AppColors.success : AppColors.textSecondary)),
        Text(t('timeline_preparing'), style: TextStyle(fontSize: 9, color: current == OrderStatus.preparing || current == OrderStatus.served ? _colors[OrderStatus.preparing] : AppColors.textSecondary)),
        Text(t('timeline_pending'), style: TextStyle(fontSize: 9, color: current == OrderStatus.pending ? _colors[OrderStatus.pending] : AppColors.textSecondary)),
      ]),
    ]);
  }

  Widget _dot(OrderStatus dot, OrderStatus current, ColorScheme cs) {
    final isReached = dot.index <= current.index;
    final c = _colors[dot]!;
    return Container(width: isReached ? 14 : 10, height: isReached ? 14 : 10,
      decoration: BoxDecoration(color: isReached ? c : cs.surface, shape: BoxShape.circle,
        border: Border.all(color: isReached ? c : cs.outlineVariant, width: 2)),
      child: isReached ? const Icon(Icons.check, size: 8, color: Colors.white) : null);
  }
}
