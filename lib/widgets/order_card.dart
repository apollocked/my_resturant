import 'package:flutter/material.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool showTime;
  final bool showTimeline;
  final VoidCallback? onNextStatus;
  final VoidCallback? onReset;
  const OrderCard({super.key, required this.order, this.showTime = false, this.showTimeline = false, this.onNextStatus, this.onReset});

  static const _colors = {OrderStatus.pending: Color(0xFFFF9800), OrderStatus.preparing: Color(0xFF2196F3), OrderStatus.served: AppTheme.success};
  static const _labels = {OrderStatus.pending: 'چاوەڕوانی', OrderStatus.preparing: 'ئامادەکراو', OrderStatus.served: 'پێشکەشکرا'};

  @override
  Widget build(BuildContext context) {
    final color = _colors[order.status]!;
    return Card(margin: const EdgeInsets.only(bottom: 10),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(_labels[order.status]!, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11))),
          Row(children: [
            Text(order.displayTable, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary)),
            const SizedBox(width: 6),
            const Icon(Icons.table_restaurant_outlined, size: 18, color: AppTheme.textSecondary),
          ]),
        ]),
        if (showTimeline) ...[
          const SizedBox(height: 12),
          _timeline(order.status),
          const SizedBox(height: 10),
        ],
        const Divider(),
        ...order.items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.primary)),
            Expanded(child: Text(item.recipe.name, textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
          ]))),
        if (order.notes.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 4), child: Text(order.notes, textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontStyle: FontStyle.italic))),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          if (showTime)
            Text('${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary))
          else if (onNextStatus != null)
            TextButton.icon(
              onPressed: onNextStatus,
              icon: Icon(Icons.arrow_forward, size: 16, color: color),
              label: Text(nextLabel[order.status]!,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: color)),
            )
          else if (onReset != null)
            TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh, size: 16, color: AppTheme.textSecondary),
              label: const Text('دووبارە', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          Text('${order.totalPrice.toInt()} د.ع', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primary)),
        ]),
      ])));
  }

  static const nextLabel = {OrderStatus.pending: 'ئامادەکردن', OrderStatus.preparing: 'پێشکەشکردن'};
  static const nextStatus = {OrderStatus.pending: OrderStatus.preparing, OrderStatus.preparing: OrderStatus.served};

  Widget _timeline(OrderStatus current) {
    return Column(children: [
      Row(children: [
        _dot(OrderStatus.served, current),
        Expanded(child: Container(height: 2, color: current == OrderStatus.served ? _colors[OrderStatus.served] : const Color(0xFFE8E4E0))),
        _dot(OrderStatus.preparing, current),
        Expanded(child: Container(height: 2, color: current == OrderStatus.preparing || current == OrderStatus.served ? _colors[OrderStatus.preparing] : const Color(0xFFE8E4E0))),
        _dot(OrderStatus.pending, current),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('پێشکەشکرا', style: TextStyle(fontSize: 9, color: current == OrderStatus.served ? AppTheme.success : AppTheme.textSecondary)),
        Text('ئامادەکراو', style: TextStyle(fontSize: 9, color: current == OrderStatus.preparing || current == OrderStatus.served ? _colors[OrderStatus.preparing] : AppTheme.textSecondary)),
        Text('چاوەڕوانی', style: TextStyle(fontSize: 9, color: current == OrderStatus.pending ? _colors[OrderStatus.pending] : AppTheme.textSecondary)),
      ]),
    ]);
  }

  Widget _dot(OrderStatus dot, OrderStatus current) {
    final isReached = dot.index <= current.index;
    final c = _colors[dot]!;
    return Container(width: isReached ? 14 : 10, height: isReached ? 14 : 10,
      decoration: BoxDecoration(color: isReached ? c : Colors.white, shape: BoxShape.circle,
        border: Border.all(color: isReached ? c : const Color(0xFFD0CCC8), width: 2)),
      child: isReached ? const Icon(Icons.check, size: 8, color: Colors.white) : null);
  }
}
