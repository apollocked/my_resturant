import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/order/calendar_grid.dart';
import 'package:my_resturant/presentation/widgets/order/clear_all_orders_dialog.dart';
import 'package:my_resturant/presentation/widgets/order/history_month_nav.dart';
import 'package:my_resturant/presentation/widgets/order/history_order_list.dart';
import 'package:my_resturant/presentation/widgets/order/history_shimmer.dart';
import 'package:my_resturant/presentation/widgets/order/history_stats_bar.dart';

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
      _goToDate(d);
    }
  }

  void _goToDate(DateTime d) {
    setState(() {
      _selectedDate = d;
      _viewMonth = DateTime(d.year, d.month);
    });
  }

  void _onDayTap(int day) {
    if (day <= DateTime.now().day ||
        _viewMonth.month < DateTime.now().month ||
        _viewMonth.year < DateTime.now().year) {
      setState(
        () => _selectedDate = DateTime(_viewMonth.year, _viewMonth.month, day),
      );
    }
  }

  void _clearAll(String Function(String) t) {
    context.read<OrderCubit>().deleteAllOrders();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t('clear_all_orders'))));
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
    final daysWithOrders = allOrders
        .where(
          (o) =>
              o.createdAt.year == _viewMonth.year &&
              o.createdAt.month == _viewMonth.month,
        )
        .map((o) => o.createdAt.day)
        .toSet();
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
              onPressed: () =>
                  showClearAllOrdersDialog(context, t, () => _clearAll(t)),
              icon: Icon(Icons.delete_sweep, color: cs.error),
              tooltip: t('clear_all_orders'),
            ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: cubit.state.isLoading && allOrders.isEmpty
            ? HistoryShimmer(padding: p)
            : Column(
                children: [
                  HistoryMonthNav(
                    t: t,
                    year: _viewMonth.year,
                    month: _viewMonth.month,
                    onPrev: () => setState(
                      () => _viewMonth = DateTime(
                        _viewMonth.year,
                        _viewMonth.month - 1,
                      ),
                    ),
                    onNext: () => setState(
                      () => _viewMonth = DateTime(
                        _viewMonth.year,
                        _viewMonth.month + 1,
                      ),
                    ),
                    onPick: _pick,
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: CalendarGrid(
                        year: _viewMonth.year,
                        month: _viewMonth.month,
                        selectedDay: _selectedDate.day,
                        daysWithOrders: daysWithOrders,
                        onDayTap: _onDayTap,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  HistoryStatsBar(
                    orderCount: dayOrders.length,
                    itemCount: dayItems,
                    total: dayTotal,
                    t: t,
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
}
