import 'package:flutter/widgets.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/order_model.dart';

class OrderStatusStyle {
  static const colors = {
    OrderStatus.pending: AppColors.warning,
    OrderStatus.preparing: AppColors.info,
    OrderStatus.served: AppColors.success,
    OrderStatus.cancelled: AppColors.error,
  };

  static Color color(OrderStatus s) => colors[s]!;

  static String label(OrderStatus s, Locale locale) => Tr.get(
    s == OrderStatus.pending
        ? 'status_pending'
        : s == OrderStatus.preparing
        ? 'status_preparing'
        : s == OrderStatus.served
        ? 'status_served'
        : 'status_cancelled',
    locale,
  );

  static String nextLabel(OrderStatus s, Locale locale) =>
      Tr.get(s == OrderStatus.pending ? 'next_prepare' : 'next_serve', locale);

  static OrderStatus next(OrderStatus s) =>
      s == OrderStatus.pending ? OrderStatus.preparing : OrderStatus.served;
}
