import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/cubits/order_cubit.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderCubit>().state;
    final counts = state.dishOrderCounts;
    final maxCount = counts.entries.firstOrNull?.value ?? 1;
    return Scaffold(
      appBar: AppBar(title: const Text('ڕاپۆرت')),
      body: Directionality(textDirection: TextDirection.rtl, child: ListView(padding: const EdgeInsets.all(20), children: [
        Row(children: [
          Expanded(child: _StatCard(icon: Icons.receipt_long, label: 'داواکاری', value: '${state.totalOrders}', color: AppTheme.primary)),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(icon: Icons.attach_money, label: 'داھات', value: '${state.totalRevenue.toInt()} د.ع', color: AppTheme.success)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _StatCard(icon: Icons.star, label: 'زۆرترین داواکراو',
            value: state.mostOrderedDish ?? '-', sub: state.totalOrders > 0 ? '${state.mostOrderedDishCount} جار' : null,
            color: const Color(0xFFFF9800))),
        ]),
        if (counts.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('ڕیزبەندی خواردنەکان', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary.withValues(alpha: 0.6))),
          const SizedBox(height: 12),
          ...counts.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
            SizedBox(width: 30, child: Text('${e.value}', textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primary))),
            const SizedBox(width: 8),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(value: e.value / maxCount, backgroundColor: const Color(0xFFF0EDEA),
                  color: AppTheme.primary, minHeight: 6))),
            const SizedBox(width: 8),
            SizedBox(width: 100, child: Text(e.key, textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.textPrimary))),
          ]))),
        ],
      ])),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final String? sub;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, this.sub, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: color)),
        const Spacer(),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ]),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary)),
      if (sub != null) Text(sub!, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
    ])));
  }
}
