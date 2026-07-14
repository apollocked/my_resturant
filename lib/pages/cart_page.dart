import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_resturant/theme/app_theme.dart';
import 'package:my_resturant/cubits/order_cubit.dart';
import 'package:my_resturant/widgets/quantity_selector.dart';
import 'package:my_resturant/widgets/table_selector.dart';
import 'package:my_resturant/widgets/app_image.dart';

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
    final state = context.watch<OrderCubit>().state;
    final cart = state.cart;

    if (cart.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 100, height: 100,
          decoration: BoxDecoration(color: const Color(0xFFF5F3F0), shape: BoxShape.circle),
          child: const Icon(Icons.shopping_bag_outlined, size: 44, color: AppTheme.textSecondary)),
        const SizedBox(height: 20),
        const Text('داواکاری نییە', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        const Text('لە مینیو خواردن هەڵبژێرە', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      ]));
    }

    return Column(children: [
      const SizedBox(height: 8),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton(onPressed: () => context.read<OrderCubit>().clearCart(),
            child: const Row(children: [
              Icon(Icons.delete_sweep, size: 18, color: AppTheme.error), SizedBox(width: 4),
              Text('سڕینەوە', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w600, fontSize: 12)),
            ])),
          TableSelector(selectedTable: state.selectedTable, onChanged: (t) => context.read<OrderCubit>().setSelectedTable(t), reservedTables: state.reservedTables),
        ])),
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
                Text(item.recipe.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text('${item.recipe.price.toInt()} د.ع', style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                SizedBox(height: 24, child: TextField(
                  textAlign: TextAlign.right, textDirection: TextDirection.rtl,
                  decoration: InputDecoration(hintText: 'تێبینی...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5), fontSize: 11),
                    border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 4), isDense: true),
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  onChanged: (v) => context.read<OrderCubit>().updateNotes(index, v),
                )),
              ])),
              const SizedBox(width: 6),
              QuantitySelector(quantity: item.quantity, onChanged: (d) => context.read<OrderCubit>().updateQuantity(index, d)),
              const SizedBox(width: 8),
              Text('${item.totalPrice.toInt()}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textPrimary)),
              const SizedBox(width: 6),
              InkWell(onTap: () => context.read<OrderCubit>().removeFromCart(index),
                child: Container(padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.close, size: 14, color: AppTheme.error))),
            ])),
          );
        },
      )),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
          border: const Border(top: BorderSide(color: Color(0xFFF0EDEA)))),
        child: SafeArea(child: Column(children: [
          TextField(controller: _notesCtrl, textAlign: TextAlign.right, textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'تێبینی گشتی بۆ داواکاری...',
              hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5), fontSize: 12)),
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SizedBox(height: 44, child: ElevatedButton(
              onPressed: () { context.read<OrderCubit>().submitOrder(_notesCtrl.text); _notesCtrl.clear(); context.go('/kitchen'); },
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Row(children: [
                Icon(Icons.send_rounded, size: 16), SizedBox(width: 6),
                Text('ناردنی داواکاری', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ]))),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${state.cartTotal.toInt()} د.ع', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppTheme.primary)),
              Text('کۆی گشتی', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppTheme.textSecondary)),
            ]),
          ]),
        ])),
      ),
    ]);
  }
}
