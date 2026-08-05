import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/order/calendar_grid.dart';
import 'package:my_resturant/presentation/widgets/order/stat_chip.dart';
import 'package:my_resturant/presentation/widgets/order/history_order_list.dart';
import 'package:my_resturant/presentation/widgets/shared/shimmer_skeletons.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});
  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _viewMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  Future<void> _pick() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (d != null) {
      if (!mounted) return;
      setState(() {
        _selectedDate = d;
        _viewMonth = DateTime(d.year, d.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<OrderCubit>();
    final allOrders = cubit.state.orders;
    final dayOrders = cubit.state.ordersByDate(_selectedDate);
    final settings = context.watch<SettingsCubit>().state;
    final role = context.watch<RoleCubit>().state.role;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final p = R.padding(context);
    final daysWithOrders = <int>{};
    for (final o in allOrders) {
      if (o.createdAt.year == _viewMonth.year &&
          o.createdAt.month == _viewMonth.month) {
        daysWithOrders.add(o.createdAt.day);
      }
    }
    final dayTotal = dayOrders.fold(0.0, (s, o) => s + o.totalPrice);
    final dayItems = dayOrders.fold(
      0,
      (s, o) => s + o.items.fold(0, (si, i) => si + i.quantity),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(t('history_title')),
        actions: [
          if (role == Role.admin && allOrders.isNotEmpty)
            IconButton(
              onPressed: () => _confirmClearAll(t, cs),
              icon: Icon(Icons.delete_sweep, color: cs.error),
              tooltip: t('clear_all_orders'),
            ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: cubit.state.isLoading && allOrders.isEmpty
            ? _buildShimmer(p)
            : Column(
                children: [
                  _monthNav(t, p),
                  CalendarGrid(
                    year: _viewMonth.year,
                    month: _viewMonth.month,
                    selectedDay: _selectedDate.day,
                    daysWithOrders: daysWithOrders,
                    onDayTap: (day) {
                      if (day <= DateTime.now().day ||
                          _viewMonth.month < DateTime.now().month ||
                          _viewMonth.year < DateTime.now().year) {
                        setState(
                          () => _selectedDate = DateTime(
                            _viewMonth.year,
                            _viewMonth.month,
                            day,
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: p, vertical: 8),
                    child: Row(
                      children: [
                        StatChip(
                          icon: Icons.receipt_long,
                          label: '${dayOrders.length} ${t('orders')}',
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        StatChip(
                          icon: Icons.shopping_bag,
                          label: '$dayItems ${t('total_items')}',
                          color: cs.tertiary,
                        ),
                        const SizedBox(width: 8),
                        StatChip(
                          icon: Icons.attach_money,
                          label:
                              '${dayTotal.toStringAsFixed(0)} ${t('currency_suffix')}',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: HistoryOrderList(
                      orders: dayOrders,
                      role: role,
                      t: t,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _monthNav(String Function(String) t, double p) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: p, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => setState(
              () =>
                  _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1),
            ),
            icon: const Icon(Icons.chevron_left),
          ),
          TextButton.icon(
            onPressed: _pick,
            icon: const Icon(Icons.calendar_month, size: 18),
            label: Text(
              '${_viewMonth.year} / ${_viewMonth.month.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: R.fontLg(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(
              () =>
                  _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1),
            ),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(double p) => Column(
    children: [
      const SizedBox(height: 8),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: p, vertical: 4),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerBox(width: 36, height: 36, radius: 8),
            ShimmerBox(width: 140, height: 36, radius: 8),
            ShimmerBox(width: 36, height: 36, radius: 8),
          ],
        ),
      ),
      const SizedBox(height: 8),
      ShimmerGrid(itemCount: 6, itemBuilder: () => const ShimmerOrderCard()),
    ],
  );

  void _confirmClearAll(String Function(String) t, ColorScheme cs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 48),
        title: Text(t('clear_all_orders')),
        content: Text(t('clear_all_orders_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OrderCubit>().deleteAllOrders();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(t('clear_all_orders'))));
            },
            child: Text(t('clear'), style: TextStyle(color: cs.onError)),
          ),
        ],
      ),
    );
  }
}
