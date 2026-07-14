import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/models/order_model.dart';
import 'package:my_resturant/models/cart_item.dart';
import 'package:my_resturant/cubits/order_cubit.dart';
import 'package:my_resturant/widgets/app_image.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;
  const OrderDetailPage({super.key, required this.order});

  static const _colors = {OrderStatus.pending: Color(0xFFFF9800), OrderStatus.preparing: Color(0xFF2196F3), OrderStatus.served: AppTheme.success};
  static const _labels = {OrderStatus.pending: 'چاوەڕوانی', OrderStatus.preparing: 'ئامادەکراو', OrderStatus.served: 'پێشکەشکرا'};
  static const _nextLabel = {OrderStatus.pending: 'ئامادەکردن', OrderStatus.preparing: 'پێشکەشکردن'};
  static const _nextStatus = {OrderStatus.pending: OrderStatus.preparing, OrderStatus.preparing: OrderStatus.served};

  @override
  Widget build(BuildContext context) {
    final color = _colors[order.status]!;
    final hasNext = _nextStatus.containsKey(order.status);
    final cubit = context.read<OrderCubit>();
    return Scaffold(
      appBar: AppBar(title: Text(order.displayTable)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Text(_labels[order.status]!, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13))),
            Text('${order.totalPrice.toInt()} د.ع', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: AppTheme.primary)),
          ]),
          const SizedBox(height: 20),
          _buildTimeline(order.status),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const Text('خواردنەکان', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ]),
          const SizedBox(height: 12),
          ...order.items.map(_itemCard),
          if (order.notes.isNotEmpty)
            Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(color: const Color(0xFFF8F6F4), borderRadius: BorderRadius.circular(10)),
              child: Text(order.notes, textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic))),
          const SizedBox(height: 32),
          if (hasNext)
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () { cubit.updateOrderStatus(order.id, _nextStatus[order.status]!); Navigator.pop(context); },
              style: FilledButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 14)),
              child: Text(_nextLabel[order.status]!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ))
          else
            SizedBox(width: double.infinity, child: OutlinedButton(
              onPressed: () { cubit.updateOrderStatus(order.id, OrderStatus.pending); Navigator.pop(context); },
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('دووبارە', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            )),
        ]),
      ),
    );
  }

  Widget _itemCard(CartItem item) {
    return Card(margin: const EdgeInsets.only(bottom: 8),
      child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
        Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.primary)),
        const SizedBox(width: 10),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: AppImage(item.recipe.imageUrl, width: 44, height: 44)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(item.recipe.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
          Text('${item.recipe.price.toInt()} د.ع', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ])),
        Text('${item.totalPrice.toInt()} د.ع', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary)),
      ])));
  }

  Widget _buildTimeline(OrderStatus current) {
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
