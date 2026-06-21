import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_resturant/viewmodels/order_viewmodel.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderViewModel>();
    final orders = viewModel.orders;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('هیچ داواکارییەک نییە',
                style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextButton.icon(
                onPressed: () => viewModel.clearOrders(),
                icon: const Icon(Icons.delete_sweep, color: Color(0xFFE53935), size: 20),
                label: const Text('سڕینەوەی هەموو',
                    style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold))),
            const Text('داواکارییەکان',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final recipe = orders[index];
                return Dismissible(
                  key: ValueKey('${recipe.id}_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                      padding: const EdgeInsets.only(left: 20),
                      color: const Color(0xFFE53935),
                      child: const Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (_) => viewModel.removeOrder(index),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(recipe.imageUrl, width: 60, height: 60, fit: BoxFit.cover)),
                    title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(recipe.description, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
                    trailing: Text('${recipe.price.toInt()} دینار',
                        style: const TextStyle(color: Color(0xFF2EC153), fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${viewModel.totalPrice.toInt()} دینار',
                  style: const TextStyle(color: Color(0xFF2EC153), fontWeight: FontWeight.bold, fontSize: 18)),
              const Text('کۆی گشتی:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
            ]),
          ),
        ],
      ),
    );
  }
}
