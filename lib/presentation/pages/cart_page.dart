import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/presentation/widgets/quantity_selector.dart';
import 'package:my_resturant/presentation/widgets/table_selector.dart';
import 'package:my_resturant/presentation/widgets/app_image.dart';
import 'package:my_resturant/presentation/widgets/settings_button.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _notesCtrl = TextEditingController();
  @override
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final state = context.watch<OrderCubit>().state;
    final cart = state.cart;

    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(children: [
          const SettingsButton(),
          const Spacer(),
          if (cart.isEmpty) const SizedBox.shrink() else ...[
            TextButton(onPressed: () => context.read<OrderCubit>().clearCart(),
              child: Row(children: [
                const Icon(Icons.delete_sweep, size: 18, color: AppColors.error), const SizedBox(width: 4),
                Text(t('clear'), style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 12)),
              ])),
            TableSelector(selectedTable: state.selectedTable, onChanged: (t) => context.read<OrderCubit>().setSelectedTable(t), reservedTables: state.reservedTables),
          ],
        ])),
      if (cart.isEmpty)
        Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 100, height: 100,
            decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_bag_outlined, size: 44, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Text(t('cart_empty_title'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(t('cart_empty_subtitle'), style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ])))
      else ...[
        const SizedBox(height: 12),
      Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cart.length,
        itemBuilder: (context, index) {
          final item = cart[index];
          return Card(margin: const EdgeInsets.only(bottom: 10),
            child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(10),
                child: AppImage(item.recipe.imageUrl, width: 56, height: 56)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(item.recipe.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('${item.recipe.price.toInt()} ${t('currency_suffix')}', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                SizedBox(height: 24, child: TextField(
                  textAlign: TextAlign.right, textDirection: TextDirection.rtl,
                  decoration: InputDecoration(hintText: t('notes_hint'),
                    hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 11),
                    border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 4), isDense: true),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  onChanged: (v) => context.read<OrderCubit>().updateNotes(index, v),
                )),
              ])),
              const SizedBox(width: 6),
              QuantitySelector(quantity: item.quantity, onChanged: (d) => context.read<OrderCubit>().updateQuantity(index, d)),
              const SizedBox(width: 8),
              Text('${item.totalPrice.toInt()}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
              const SizedBox(width: 6),
              InkWell(onTap: () => context.read<OrderCubit>().removeFromCart(index),
                child: Container(padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.close, size: 14, color: AppColors.error))),
            ])),
          );
        },
      )),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(color: cs.surface,
          boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
          border: Border(top: BorderSide(color: cs.outlineVariant))),
        child: SafeArea(child: Column(children: [
          TextField(controller: _notesCtrl, textAlign: TextAlign.right, textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: t('general_notes_hint'),
              hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 12)),
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SizedBox(height: 44, child: ElevatedButton(
              onPressed: () { context.read<OrderCubit>().submitOrder(_notesCtrl.text); _notesCtrl.clear(); context.go('/kitchen'); },
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Row(children: [
                const Icon(Icons.send_rounded, size: 16), const SizedBox(width: 6),
                Text(t('send_order'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ]))),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${state.cartTotal.toInt()} ${t('currency_suffix')}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.primary)),
              Text(t('total'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ]),
        ])),
      ),
    ],
    ]);
  }
}
