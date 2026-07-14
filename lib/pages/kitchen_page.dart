import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/models/order_model.dart';
import 'package:my_resturant/cubits/order_cubit.dart';

class KitchenPage extends StatelessWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderCubit>().state.orders;
    return Scaffold(
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text('${orders.length} داواکاری',
                  style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            const Text('چێشتخانە', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          ]),
        ),
        const SizedBox(height: 16),
        if (orders.isEmpty)
          Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 100, height: 100, decoration: BoxDecoration(color: const Color(0xFFF5F3F0), shape: BoxShape.circle),
              child: const Icon(Icons.receipt_long_outlined, size: 44, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            const Text('هیچ داواکارییەک نەنێردراوە',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ])))
        else
          Expanded(
            child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: orders.length,
              itemBuilder: (context, index) => _OrderCard(order: orders[index]),
            ),
          ),
      ])),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  static const _colors = {OrderStatus.pending: Color(0xFFFF9800), OrderStatus.preparing: Color(0xFF2196F3), OrderStatus.served: AppTheme.success};
  static const _labels = {OrderStatus.pending: 'چاوەڕوانی', OrderStatus.preparing: 'ئامادەکراو', OrderStatus.served: 'پێشکەشکرا'};
  static const _nextStatus = {OrderStatus.pending: OrderStatus.preparing, OrderStatus.preparing: OrderStatus.served};
  static const _nextLabel = {OrderStatus.pending: 'ئامادەکردن', OrderStatus.preparing: 'پێشکەشکردن'};

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrderCubit>();
    final color = _colors[order.status]!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(_labels[order.status]!, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
          ),
          Row(children: [
            Text(order.displayTable, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary)),
            const SizedBox(width: 6),
            const Icon(Icons.table_restaurant_outlined, size: 18, color: AppTheme.textSecondary),
          ]),
        ]),
        const SizedBox(height: 12),
        // Status timeline
        Row(children: [
          _statusDot(OrderStatus.served, order.status),
          Expanded(child: Container(height: 2, color: order.status == OrderStatus.served ? _colors[OrderStatus.served] : const Color(0xFFE8E4E0))),
          _statusDot(OrderStatus.preparing, order.status),
          Expanded(child: Container(height: 2, color: order.status == OrderStatus.preparing || order.status == OrderStatus.served ? _colors[OrderStatus.preparing] : const Color(0xFFE8E4E0))),
          _statusDot(OrderStatus.pending, order.status),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('پێشکەشکرا', style: TextStyle(fontSize: 9, color: order.status == OrderStatus.served ? AppTheme.success : AppTheme.textSecondary)),
          Text('ئامادەکراو', style: TextStyle(fontSize: 9, color: order.status == OrderStatus.preparing || order.status == OrderStatus.served ? _colors[OrderStatus.preparing] : AppTheme.textSecondary)),
          Text('چاوەڕوانی', style: TextStyle(fontSize: 9, color: order.status == OrderStatus.pending ? _colors[OrderStatus.pending] : AppTheme.textSecondary)),
        ]),
        const SizedBox(height: 10),
        const Divider(),
        ...order.items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.primary)),
            Expanded(child: Text(item.recipe.name, textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
          ]),
        )),
        if (order.notes.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 4),
            child: Text(order.notes, textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontStyle: FontStyle.italic))),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          if (_nextStatus.containsKey(order.status))
            TextButton.icon(
              onPressed: () => cubit.updateOrderStatus(order.id, _nextStatus[order.status]!),
              icon: Icon(Icons.arrow_forward, size: 16, color: color),
              label: Text(_nextLabel[order.status]!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: color)),
            )
          else
            TextButton.icon(
              onPressed: () => cubit.updateOrderStatus(order.id, OrderStatus.pending),
              icon: const Icon(Icons.refresh, size: 16, color: AppTheme.textSecondary),
              label: const Text('دووبارە', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          Text('${order.totalPrice.toInt()} د.ع',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primary)),
        ]),
      ])),
    );
  }

  Widget _statusDot(OrderStatus dot, OrderStatus current) {
    final isReached = dot.index <= current.index;
    final c = _colors[dot]!;
    return Container(
      width: isReached ? 14 : 10, height: isReached ? 14 : 10,
      decoration: BoxDecoration(
        color: isReached ? c : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: isReached ? c : const Color(0xFFD0CCC8), width: 2)),
      child: isReached ? const Icon(Icons.check, size: 8, color: Colors.white) : null,
    );
  }
}
