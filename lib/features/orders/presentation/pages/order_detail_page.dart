import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/features/orders/domain/entities/order_model.dart';
import 'package:my_resturant/features/auth/domain/entities/role.dart';
import 'package:my_resturant/features/orders/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/features/auth/presentation/cubits/role_cubit.dart';
import 'package:my_resturant/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_detail_body.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_detail_page_actions.dart';
import 'package:my_resturant/features/orders/presentation/widgets/order_status_style.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;
  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final color = OrderStatusStyle.color(order.status);
    final cubit = context.read<OrderCubit>();
    final role = context.watch<RoleCubit>().state.role;
    final canEdit = role != Role.waiter;
    final canPlaceItems = role != Role.kitchen;
    final isDesktop = !R.isPhone(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${order.displayTable} — ${order.displayTrackingCode}'),
        actions: [
          IconButton(
            onPressed: () => showPrintDialog(context, order, t),
            icon: const Icon(Icons.print, size: 22),
            tooltip: t('print_receipt'),
          ),
        ],
      ),
      floatingActionButton: canPlaceItems
          ? FloatingActionButton.extended(
              onPressed: () => showAddOrderItemsSheet(context, order),
              backgroundColor: AppColors.primary,
              foregroundColor: cs.onPrimary,
              icon: const Icon(Icons.add_shopping_cart, size: 20),
              label: Text(
                t('add_items'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: R.isPhone(context) ? 100 : 40,
            left: R.padding(context),
            right: R.padding(context),
            top: R.padding(context),
          ),
          child: OrderDetailBody(
            order: order,
            color: color,
            cs: cs,
            t: t,
            cubit: cubit,
            locale: settings.locale,
            canEdit: canEdit,
            isDesktop: isDesktop,
          ),
        ),
      ),
    );
  }
}