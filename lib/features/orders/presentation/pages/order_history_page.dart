import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/features/auth/domain/entities/role.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/features/auth/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/features/orders/presentation/widgets/clear_all_orders_dialog.dart';
import 'package:my_resturant/features/orders/presentation/widgets/history_calendar_view.dart';
import 'package:my_resturant/features/orders/presentation/widgets/history_layout.dart';

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

  void _shiftMonth(int delta) {
    setState(
      () => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + delta),
    );
  }

  void _onDayTap(int day) {
    final now = DateTime.now();
    final isFutureMonth =
        _viewMonth.year > now.year ||
        (_viewMonth.year == now.year && _viewMonth.month > now.month);
    if (isFutureMonth) return;
    final isCurrentMonth =
        _viewMonth.year == now.year && _viewMonth.month == now.month;
    if (isCurrentMonth && day > now.day) return;
    setState(
      () => _selectedDate = DateTime(_viewMonth.year, _viewMonth.month, day),
    );
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
      body: HistoryLayout(
        calendar: HistoryCalendarView(
          t: t,
          viewMonth: _viewMonth,
          selectedDate: _selectedDate,
          orders: allOrders,
          onDayTap: _onDayTap,
          onPrev: () => _shiftMonth(-1),
          onNext: () => _shiftMonth(1),
          onPick: _pick,
          hPad: p,
        ),
        loading: cubit.state.isLoading,
        isEmpty: allOrders.isEmpty,
        dayOrders: dayOrders,
        t: t,
        padding: p,
        outlineVariant: cs.outlineVariant,
      ),
    );
  }
}