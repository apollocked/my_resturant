import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/models/order_model.dart';
import 'package:my_resturant/cubits/order_cubit.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});
  @override State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  DateTime _date = DateTime.now();

  Future<void> _pick() async {
    final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2024), lastDate: DateTime.now());
    if (d != null) setState(() => _date = d);
  }

  String _fmt(DateTime d) => '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderCubit>().state.ordersByDate(_date);
    return Scaffold(
      appBar: AppBar(title: const Text('مێژووی داواکاری')),
      body: Directionality(textDirection: TextDirection.rtl, child: Column(children: [
        const SizedBox(height: 12),
        TextButton.icon(onPressed: _pick,
          icon: const Icon(Icons.calendar_month, size: 18),
          label: Text(_fmt(_date), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          style: TextButton.styleFrom(foregroundColor: AppTheme.primary)),
        const Divider(),
        if (orders.isEmpty)
          Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFFF5F3F0), shape: BoxShape.circle),
              child: const Icon(Icons.history, size: 36, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            const Text('هیچ داواکارییەک نییە', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ])))
        else
          Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: orders.length,
            itemBuilder: (context, index) => _OrderHistoryCard(order: orders[index]),
          )),
      ])),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final Order order;
  const _OrderHistoryCard({required this.order});

  static const _colors = {OrderStatus.pending: Color(0xFFFF9800), OrderStatus.preparing: Color(0xFF2196F3), OrderStatus.served: AppTheme.success};
  static const _labels = {OrderStatus.pending: 'چاوەڕوانی', OrderStatus.preparing: 'ئامادەکراو', OrderStatus.served: 'پێشکەشکرا'};

  @override
  Widget build(BuildContext context) {
    final color = _colors[order.status]!;
    return Card(margin: const EdgeInsets.only(bottom: 10),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(_labels[order.status]!, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))),
          Text(order.displayTable, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary)),
        ]),
        const SizedBox(height: 10),
        ...order.items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.primary)),
            Text(item.recipe.name, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
          ]))),
        const Divider(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${order.totalPrice.toInt()} د.ع', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primary)),
          Text('${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ]),
      ])));
  }
}
