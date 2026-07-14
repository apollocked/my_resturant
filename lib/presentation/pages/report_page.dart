import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/stat_card.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderCubit>().state;
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final counts = state.dishOrderCounts;
    final maxCount = counts.entries.firstOrNull?.value ?? 1;
    return Scaffold(
      appBar: AppBar(title: Text(t('report'))),
      body: Directionality(textDirection: TextDirection.rtl, child: ListView(padding: const EdgeInsets.all(20), children: [
        Row(children: [
          Expanded(child: StatCard(icon: Icons.receipt_long, label: t('cart'), value: '${state.totalOrders}', color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(child: StatCard(icon: Icons.attach_money, label: t('revenue'), value: '${state.totalRevenue.toInt()} ${t('currency_suffix')}', color: AppColors.success)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: StatCard(icon: Icons.star, label: t('most_ordered'),
            value: state.mostOrderedDish ?? '-', sub: state.totalOrders > 0 ? '${state.mostOrderedDishCount} ${t('times')}' : null,
            color: Colors.orange)),
        ]),
        if (counts.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(t('foods_ranking'), style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary.withValues(alpha: 0.6))),
          const SizedBox(height: 12),
          ...counts.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
            SizedBox(width: 30, child: Text('${e.value}', textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary))),
            const SizedBox(width: 8),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(value: e.value / maxCount, backgroundColor: cs.outlineVariant,
                  color: AppColors.primary, minHeight: 6))),
            const SizedBox(width: 8),
            SizedBox(width: 100, child: Text(e.key, textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary))),
          ]))),
        ],
      ])),
    );
  }
}
