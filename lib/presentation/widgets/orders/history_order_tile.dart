import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/order_model.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/orders/order_status_style.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class HistoryOrderTile extends StatelessWidget {
  final Order order;
  final String Function(String) t;
  const HistoryOrderTile({super.key, required this.order, required this.t});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = context.watch<SettingsCubit>().state.locale;
    final isDesktop = R.screenSize(context) == ScreenSize.desktop;
    final statusColor = OrderStatusStyle.color(order.status);
    final time =
        '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';
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
            _header(context, statusColor, time, isDesktop),
            Padding(
              padding: EdgeInsets.symmetric(vertical: isDesktop ? 8 : 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _tableRow(context, isDesktop),
                  const SizedBox(height: 5),
                  _statusChip(context, statusColor, locale, isDesktop),
                  const SizedBox(height: 6),
                  Text(
                    '${order.totalPrice.toInt()} ${t('currency_suffix')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: isDesktop
                          ? R.fontXl(context)
                          : R.fontLg(context),
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context,
    Color statusColor,
    String time,
    bool isDesktop,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 6 : 4,
        horizontal: 10,
      ),
      color: statusColor.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              _shortCode,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: R.fontSm(context) - 1,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: R.fontSm(context) - 2,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(BuildContext context, bool isDesktop) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.table_restaurant_outlined,
          size: isDesktop ? 16 : 14,
          color: AppColors.primary,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            order.displayTable,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: R.fontSm(context) - 1,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(
    BuildContext context,
    Color statusColor,
    Locale locale,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 10 : 8,
        vertical: isDesktop ? 5 : 3,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        OrderStatusStyle.label(order.status, locale),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: R.fontSm(context) - 2,
          fontWeight: FontWeight.w700,
          color: statusColor,
        ),
      ),
    );
  }

  String get _shortCode {
    final digits = order.displayTrackingCode.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 6) return '#$digits';
    return '#${digits.substring(digits.length - 6)}';
  }
}
