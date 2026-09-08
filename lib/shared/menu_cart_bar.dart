import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/widgets/orders/cart_send_button.dart';
import 'package:my_resturant/presentation/widgets/orders/cart_total_column.dart';

class MenuCartBar extends StatelessWidget {
  final int cartCount;
  final int cartTotal;
  final VoidCallback? onViewCart;
  const MenuCartBar({
    super.key,
    required this.cartCount,
    required this.cartTotal,
    this.onViewCart,
  });
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);
    String t(String key) => Tr.get(key, settings.state.locale);
    return Padding(
      padding: EdgeInsets.only(
        bottom: R.bottomBarClearance(context),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          R.padding(context),
          isDesktop ? 16 : 12,
          R.padding(context),
          isDesktop ? 16 : 12,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        child: Row(
          children: [
            CartSendButton(
              canSubmit: true,
              isSubmitting: false,
              onSubmit: onViewCart ?? () {},
              cs: cs,
              label: t('view_order'),
              fontSize: isDesktop ? 16 : 14,
              padH: isDesktop ? 32 : 24,
              icon: Icons.shopping_bag,
            ),
            const Spacer(),
            CartTotalColumn(
              total: cartTotal.toDouble(),
              currencySuffix: t('currency_suffix'),
              totalLabel: t('total'),
              cs: cs,
            ),
          ],
        ),
      ),
    );
  }
}
