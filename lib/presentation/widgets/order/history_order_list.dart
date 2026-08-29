import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/shared/empty_state.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class HistoryOrderList extends StatelessWidget {
  final List<Order> orders;
  final String Function(String) t;
  const HistoryOrderList({
    super.key,
    required this.orders,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final p = R.padding(context);
    if (orders.isEmpty) {
      return EmptyState(
        icon: Icons.history,
        title: t('history_empty'),
        subtitle: t('history_empty_subtitle'),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context.read<OrderCubit>().refresh(),
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(p, 0, p, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: orders.length,
        itemBuilder: (ctx, i) => _tile(ctx, orders[i]),
      ),
    );
  }

  Widget _tile(BuildContext context, Order order) {
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.screenSize(context) == ScreenSize.desktop;
    return PressableScale(
      onTap: () => context.push('/order-detail', extra: order),
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isDesktop ? 6 : 4,
                horizontal: 8,
              ),
              color: AppColors.primary.withValues(alpha: 0.08),
              child: Text(
                _shortCode(order),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.fontSm(context) - 1,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${order.totalPrice.toInt()} ${t('currency_suffix')}',
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: R.fontLg(context),
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortCode(Order order) {
    final digits = order.displayTrackingCode.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 6) return '#$digits';
    return '#${digits.substring(digits.length - 6)}';
  }
}
