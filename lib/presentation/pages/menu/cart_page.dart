import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/orders/cart_bottom_bar.dart';
import 'package:my_resturant/presentation/widgets/orders/cart_header_bar.dart';
import 'package:my_resturant/presentation/widgets/orders/cart_items_list.dart';
import 'package:my_resturant/shared/empty_state.dart';

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
    for (final c in _itemNotesCtls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _notesCtl(String recipeId, String existing) {
    final c = _itemNotesCtls.putIfAbsent(
      recipeId,
      () => TextEditingController(),
    );
    if (c.text != existing) c.text = existing;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final state = context.watch<OrderCubit>().state;
    final cart = state.cart;
    final cubit = context.read<OrderCubit>();

    return Column(
      children: [
        CartHeaderBar(
          cartNotEmpty: cart.isNotEmpty,
          t: t,
          onClear: () => cubit.clearCart(),
          selectedTable: state.selectedTable,
          onTableChanged: (t) => cubit.setSelectedTable(t),
          reservedTables: state.reservedTables,
        ),
        if (cart.isEmpty)
          Expanded(
            child: EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: t('cart_empty_title'),
              subtitle: t('cart_empty_subtitle'),
            ),
          )
        else ...[
          const SizedBox(height: 8),
          CartItemsList(
            cart: cart,
            notesCtl: _notesCtl,
            notesHint: t('notes_hint'),
          ),
          CartBottomBar(
            notesCtrl: _notesCtrl,
            notesHint: t('general_notes_hint'),
            totalLabel: t('total'),
            sendLabel: t('send_order'),
            currencySuffix: t('currency_suffix'),
            total: state.cartTotal,
            canSubmit:
                state.selectedTable > 0 &&
                cart.isNotEmpty &&
                !state.isSubmitting,
            isSubmitting: state.isSubmitting,
            onSubmit: () async {
              final notes = _notesCtrl.text;
              final ok = await cubit.submitOrder(notes);
              if (!ok) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t('error_occurred'))),
                );
                return;
              }
              _notesCtrl.clear();
              if (!context.mounted) return;
              context.go('/kitchen');
            },
          ),
        ],
      ],
    );
  }
}
