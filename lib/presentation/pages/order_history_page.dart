import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/order/order_card.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

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
    final settings = context.watch<SettingsCubit>().state;
    final role = context.watch<RoleCubit>().state.role;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);
    return Scaffold(
      appBar: AppBar(title: Text(t('history_title'))),
      body: SafeArea(child: Directionality(textDirection: TextDirection.rtl, child: Column(children: [
        const SizedBox(height: 12),
        TextButton.icon(onPressed: _pick, icon: const Icon(Icons.calendar_month, size: 18),
          label: Text(_fmt(_date), style: TextStyle(fontSize: R.fontLg(context), fontWeight: FontWeight.w600)),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary)),
        const Divider(),
        if (orders.isEmpty)
          Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: R.hp(context, isDesktop ? 16 : 18), height: R.hp(context, isDesktop ? 16 : 18),
              decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
              child: Icon(Icons.history, size: isDesktop ? 48 : 36, color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            Text(t('history_empty'), style: TextStyle(fontSize: R.fontLg(context), fontWeight: FontWeight.w600, color: cs.onSurface)),
          ])))
        else
          Expanded(child: RefreshIndicator(
            onRefresh: () async => context.read<OrderCubit>().refresh(),
            child: isDesktop
              ? GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: R.gridSpacing(context),
                    mainAxisSpacing: R.gridSpacing(context),
                  ),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return OrderCard(order: order, showTime: true,
                      onReset: role == Role.admin ? () {
                        final cubit = context.read<OrderCubit>();
                        for (final item in order.items) {
                          for (int i = 0; i < item.quantity; i++) {
                            cubit.addToCart(item.recipe);
                          }
                        }
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('order_restored'))));
                        if (context.mounted) context.read<OrderCubit>().refresh();
                      } : null);
                  },
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return OrderCard(order: order, showTime: true,
                      onReset: role == Role.admin ? () {
                        final cubit = context.read<OrderCubit>();
                        for (final item in order.items) {
                          for (int i = 0; i < item.quantity; i++) {
                            cubit.addToCart(item.recipe);
                          }
                        }
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('order_restored'))));
                        if (context.mounted) context.read<OrderCubit>().refresh();
                      } : null);
                  },
                ),
          )),
      ]))),
    );
  }
}
