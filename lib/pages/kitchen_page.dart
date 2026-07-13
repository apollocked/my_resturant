import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_resturant/models/order_model.dart';
import 'package:my_resturant/viewmodels/order_viewmodel.dart';

class KitchenPage extends StatelessWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderViewModel>().orders;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('هیچ داواکارییەک نەنێردراوە',
                style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(context, order);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final viewModel = context.read<OrderViewModel>();
    final statusColors = {
      OrderStatus.pending: const Color(0xFFFF9800),
      OrderStatus.preparing: const Color(0xFF2196F3),
      OrderStatus.served: const Color(0xFF2EC153),
    };
    final statusLabels = {
      OrderStatus.pending: 'چاوەڕوانی',
      OrderStatus.preparing: 'ئامادەکراو',
      OrderStatus.served: 'پێشکەشکرا',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColors[order.status]!.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(statusLabels[order.status]!,
                  style: TextStyle(color: statusColors[order.status], fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            Row(children: [
              Text('مێز: ${order.tableNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 6),
              const Icon(Icons.table_restaurant, size: 18),
            ]),
          ]),
          const Divider(height: 16),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${item.quantity}x',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Expanded(
                child: Text(item.recipe.name,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            ]),
          )),
          if (order.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('تێبینی: ${order.notes}',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              if (order.status == OrderStatus.pending)
                _statusButton('ئامادەکردن', OrderStatus.preparing, viewModel, order)
              else if (order.status == OrderStatus.preparing)
                _statusButton('پێشکەشکردن', OrderStatus.served, viewModel, order)
              else
                TextButton.icon(
                  onPressed: () => viewModel.updateOrderStatus(order.id, OrderStatus.pending),
                  icon: const Icon(Icons.refresh, size: 16, color: Colors.grey),
                  label: const Text('دووبارە', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
            ]),
            Text('${order.totalPrice.toInt()} دینار',
                style: const TextStyle(color: Color(0xFF2EC153), fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
        ]),
      ),
    );
  }

  Widget _statusButton(String label, OrderStatus status, OrderViewModel vm, Order order) {
    return TextButton(
      onPressed: () => vm.updateOrderStatus(order.id, status),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2EC153))),
    );
  }
}
