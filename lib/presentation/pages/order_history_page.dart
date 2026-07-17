import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/role.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/order/order_card.dart';
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
      setState(() {
        _selectedDate = d;
        _viewMonth = DateTime(d.year, d.month);
      });
    }
  }

  void _prevMonth() => setState(
    () => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1),
  );
  void _nextMonth() => setState(
    () => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1),
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<OrderCubit>();
    final allOrders = cubit.state.orders;
    final dayOrders = cubit.state.ordersByDate(_selectedDate);
    final settings = context.watch<SettingsCubit>().state;
    final role = context.watch<RoleCubit>().state.role;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);
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
    final dayCount = dayOrders.length;

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
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: cubit.state.isLoading && allOrders.isEmpty
              ? Column(
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
                    ShimmerGrid(
                      itemCount: 6,
                      itemBuilder: () => const ShimmerOrderCard(),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: p, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _prevMonth,
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
                            onPressed: _nextMonth,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                    _CalendarGrid(
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
                          _StatChip(
                            icon: Icons.receipt_long,
                            label: '$dayCount ${t('orders')}',
                            color: AppColors.primary,
                            cs: cs,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            icon: Icons.shopping_bag,
                            label: '$dayItems ${t('total_items')}',
                            color: cs.tertiary,
                            cs: cs,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            icon: Icons.attach_money,
                            label:
                                '${dayTotal.toStringAsFixed(0)} ${t('currency_suffix')}',
                            color: Colors.green,
                            cs: cs,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    if (dayOrders.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: R.hp(context, isDesktop ? 16 : 18),
                                height: R.hp(context, isDesktop ? 16 : 18),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.history,
                                  size: isDesktop ? 48 : 36,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t('history_empty'),
                                style: TextStyle(
                                  fontSize: R.fontLg(context),
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async =>
                              context.read<OrderCubit>().refresh(),
                          child: isDesktop
                              ? GridView.builder(
                                  padding: EdgeInsets.symmetric(horizontal: p),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 1.0,
                                        crossAxisSpacing: R.gridSpacing(
                                          context,
                                        ),
                                        mainAxisSpacing: R.gridSpacing(context),
                                      ),
                                  itemCount: dayOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = dayOrders[index];
                                    return OrderCard(
                                      order: order,
                                      showTime: true,
                                      onReset: role == Role.admin
                                          ? () {
                                              final c = context
                                                  .read<OrderCubit>();
                                              for (final item in order.items) {
                                                for (
                                                  int i = 0;
                                                  i < item.quantity;
                                                  i++
                                                ) {
                                                  c.addToCart(item.recipe);
                                                }
                                              }
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    t('order_restored'),
                                                  ),
                                                ),
                                              );
                                              if (context.mounted) {
                                                context
                                                    .read<OrderCubit>()
                                                    .refresh();
                                              }
                                            }
                                          : null,
                                    );
                                  },
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.symmetric(horizontal: p),
                                  itemCount: dayOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = dayOrders[index];
                                    return OrderCard(
                                      order: order,
                                      showTime: true,
                                      onReset: role == Role.admin
                                          ? () {
                                              final c = context
                                                  .read<OrderCubit>();
                                              for (final item in order.items) {
                                                for (
                                                  int i = 0;
                                                  i < item.quantity;
                                                  i++
                                                ) {
                                                  c.addToCart(item.recipe);
                                                }
                                              }
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    t('order_restored'),
                                                  ),
                                                ),
                                              );
                                              if (context.mounted) {
                                                context
                                                    .read<OrderCubit>()
                                                    .refresh();
                                              }
                                            }
                                          : null,
                                    );
                                  },
                                ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final int year, month, selectedDay;
  final Set<int> daysWithOrders;
  final ValueChanged<int> onDayTap;

  const _CalendarGrid({
    required this.year,
    required this.month,
    required this.selectedDay,
    required this.daysWithOrders,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final first = DateTime(year, month);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final wd = first.weekday;
    final satStartIndex = (wd + 1) % 7;
    final now = DateTime.now();

    final cells = <Widget>[];
    for (int i = 0; i < satStartIndex; i++) {
      cells.add(const SizedBox());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final isSelected = d == selectedDay;
      final hasOrder = daysWithOrders.contains(d);
      final isFuture = DateTime(year, month, d).isAfter(now);
      cells.add(
        GestureDetector(
          onTap: isFuture ? null : () => onDayTap(d),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$d',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isFuture
                              ? cs.onSurface.withValues(alpha: 0.3)
                              : cs.onSurface),
                  ),
                ),
                if (hasOrder)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    final remaining = (7 - cells.length % 7) % 7;
    for (int i = 0; i < remaining; i++) {
      cells.add(const SizedBox());
    }

    final rows = <Widget>[
      Row(
        children: ['S', 'S', 'M', 'T', 'W', 'T', 'F']
            .map(
              (l) => Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      l,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(
        Row(
          children: cells
              .sublist(i, i + 7)
              .map((c) => Expanded(child: SizedBox(height: 38, child: c)))
              .toList(),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(children: rows),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ColorScheme cs;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.cs,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
