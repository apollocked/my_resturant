import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/order/cart_item_card.dart';
import 'package:my_resturant/presentation/widgets/order/cart_bottom_bar.dart';
import 'package:my_resturant/presentation/widgets/shared/empty_state.dart';
import 'package:my_resturant/presentation/widgets/shared/table_selector.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _notesCtrl = TextEditingController();
  final _itemNotesCtls = <String, TextEditingController>{};

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final c in _itemNotesCtls.values) { c.dispose(); }
    super.dispose();
  }

  TextEditingController _notesCtl(String recipeId, String existing) {
    final c = _itemNotesCtls.putIfAbsent(recipeId, () => TextEditingController());
    if (c.text != existing) c.text = existing;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final state = context.watch<OrderCubit>().state;
    final cart = state.cart;
    final isDesktop = R.isDesktop(context);

    return SafeArea(child: Column(children: [
      Padding(
        padding: EdgeInsets.fromLTRB(R.padding(context), 8, R.padding(context), 0),
        child: Row(children: [
          const Spacer(),
          if (cart.isNotEmpty) ...[
            TextButton.icon(
              onPressed: () => context.read<OrderCubit>().clearCart(),
              icon: const Icon(Icons.delete_sweep, size: 18),
              label: Text(t('clear'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: R.fontSm(context))),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
            ),
            SizedBox(width: isDesktop ? 16 : 8),
            TableSelector(selectedTable: state.selectedTable,
              onChanged: (t) => context.read<OrderCubit>().setSelectedTable(t),
              reservedTables: state.reservedTables),
          ],
        ]),
      ),
      if (cart.isEmpty)
        Expanded(child: EmptyState(icon: Icons.shopping_bag_outlined, title: t('cart_empty_title'), subtitle: t('cart_empty_subtitle')))
      else ...[
        const SizedBox(height: 8),
        Expanded(child: isDesktop
          ? GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.15,
                crossAxisSpacing: R.gridSpacing(context),
                mainAxisSpacing: R.gridSpacing(context),
              ),
              itemCount: cart.length,
              itemBuilder: (context, index) => CartItemCard(
                item: cart[index], index: index,
                notesCtl: _notesCtl, notesHint: t('notes_hint'),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
              itemCount: cart.length,
              itemBuilder: (context, index) => CartItemCard(
                item: cart[index], index: index,
                notesCtl: _notesCtl, notesHint: t('notes_hint'),
              ),
            ),
        ),
        CartBottomBar(
          notesCtrl: _notesCtrl, notesHint: t('general_notes_hint'),
          totalLabel: t('total'), sendLabel: t('send_order'),
          currencySuffix: t('currency_suffix'), total: state.cartTotal,
          canSubmit: state.selectedTable > 0 && cart.isNotEmpty,
          onSubmit: () { context.read<OrderCubit>().submitOrder(_notesCtrl.text); _notesCtrl.clear(); context.go('/kitchen'); },
        ),
      ],
    ]));
  }
}
