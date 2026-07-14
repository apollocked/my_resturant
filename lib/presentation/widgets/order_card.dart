import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/order_model.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool showTime;
  final bool showTimeline;
  final VoidCallback? onNextStatus;
  final VoidCallback? onReset;
  const OrderCard({super.key, required this.order, this.showTime = false, this.showTimeline = false, this.onNextStatus, this.onReset});

  static const _colors = {OrderStatus.pending: Colors.orange, OrderStatus.preparing: Colors.blue, OrderStatus.served: AppColors.success};

  static String _label(OrderStatus s, Locale locale) => Tr.get(
    s == OrderStatus.pending ? 'status_pending' : s == OrderStatus.preparing ? 'status_preparing' : 'status_served', locale);

  static String _nextLabel(OrderStatus s, Locale locale) => Tr.get(
    s == OrderStatus.pending ? 'next_prepare' : 'next_serve', locale);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    final locale = settings.state.locale;
    final cs = Theme.of(context).colorScheme;
    final color = _colors[order.status]!;
    return Card(margin: const EdgeInsets.only(bottom: 10),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(_label(order.status, locale), style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11))),
          Row(children: [
            Text(order.displayTable, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
            const SizedBox(width: 6),
            const Icon(Icons.table_restaurant_outlined, size: 18, color: AppColors.textSecondary),
          ]),
        ]),
        if (showTimeline) ...[
          const SizedBox(height: 12),
          _timeline(order.status, cs, locale),
          const SizedBox(height: 10),
        ],
        const Divider(),
        ...order.items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary)),
            Expanded(child: Text(item.recipe.name, textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
          ]))),
        if (order.notes.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 4), child: Text(order.notes, textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic))),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          if (showTime)
            Text('${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))
          else if (onNextStatus != null)
            TextButton.icon(
              onPressed: onNextStatus,
              icon: Icon(Icons.arrow_forward, size: 16, color: color),
              label: Text(_nextLabel(order.status, locale),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: color)),
            )
          else if (onReset != null)
            TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh, size: 16, color: AppColors.textSecondary),
              label: Text(Tr.get('again', locale), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          Text('${order.totalPrice.toInt()} ${Tr.get('currency_suffix', locale)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
        ]),
      ])));
  }

  static const nextStatus = {OrderStatus.pending: OrderStatus.preparing, OrderStatus.preparing: OrderStatus.served};

  Widget _timeline(OrderStatus current, ColorScheme cs, Locale locale) {
    return Column(children: [
      Row(children: [
        _dot(OrderStatus.served, current, cs),
        Expanded(child: Container(height: 2, color: current == OrderStatus.served ? _colors[OrderStatus.served] : cs.outlineVariant)),
        _dot(OrderStatus.preparing, current, cs),
        Expanded(child: Container(height: 2, color: current == OrderStatus.preparing || current == OrderStatus.served ? _colors[OrderStatus.preparing] : cs.outlineVariant)),
        _dot(OrderStatus.pending, current, cs),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(Tr.get('timeline_served', locale), style: TextStyle(fontSize: 9, color: current == OrderStatus.served ? AppColors.success : AppColors.textSecondary)),
        Text(Tr.get('timeline_preparing', locale), style: TextStyle(fontSize: 9, color: current == OrderStatus.preparing || current == OrderStatus.served ? _colors[OrderStatus.preparing] : AppColors.textSecondary)),
        Text(Tr.get('timeline_pending', locale), style: TextStyle(fontSize: 9, color: current == OrderStatus.pending ? _colors[OrderStatus.pending] : AppColors.textSecondary)),
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
