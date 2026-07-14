import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/cubits/order_cubit.dart';
import 'package:my_resturant/widgets/order_card.dart';

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
        TextButton.icon(onPressed: _pick, icon: const Icon(Icons.calendar_month, size: 18),
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
          Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: orders.length,
            itemBuilder: (context, index) => OrderCard(order: orders[index], showTime: true))),
      ])),
    );
  }
}
