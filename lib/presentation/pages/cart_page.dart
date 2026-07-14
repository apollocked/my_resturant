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
import 'package:my_resturant/core/helpers/responsive.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _notesCtrl = TextEditingController();
  final _itemNotesCtls = <int, TextEditingController>{};

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final c in _itemNotesCtls.values) { c.dispose(); }
    super.dispose();
  }

  TextEditingController _notesCtl(int index, String existing) {
    return _itemNotesCtls.putIfAbsent(index, () => TextEditingController(text: existing));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    String t(String key) => Tr.get(key, settings.locale);
    final cs = Theme.of(context).colorScheme;
    final state = context.watch<OrderCubit>().state;
    final cart = state.cart;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(R.padding(context), 8, R.padding(context), 0),
            child: Row(
              children: [
                const Spacer(),
                if (cart.isEmpty)
                  const SizedBox.shrink()
                else ...[
                  TextButton.icon(
                    onPressed: () => context.read<OrderCubit>().clearCart(),
                    icon: const Icon(Icons.delete_sweep, size: 18),
                    label: Text(t('clear'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  ),
                  const SizedBox(width: 8),
                  TableSelector(
                    selectedTable: state.selectedTable,
                    onChanged: (t) => context.read<OrderCubit>().setSelectedTable(t),
                    reservedTables: state.reservedTables,
                  ),
                ],
              ],
            ),
          ),
          if (cart.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
                      child: Icon(Icons.shopping_bag_outlined, size: 44, color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                    Text(t('cart_empty_title'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
                    const SizedBox(height: 6),
                    Text(t('cart_empty_subtitle'), style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          else ...[
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: R.padding(context)),
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final item = cart[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: EdgeInsets.all(R.cardPadding(context)),
                      child: Column(children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          ClipRRect(borderRadius: BorderRadius.circular(12),
                            child: AppImage(item.recipe.imageUrl, width: 64, height: 64)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Row(children: [
                                InkWell(
                                  onTap: () => context.read<OrderCubit>().removeFromCart(index),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(width: 32, height: 32, alignment: Alignment.center,
                                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.close, size: 16, color: AppColors.error)),
                                ),
                                const Spacer(),
                                Text(item.recipe.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cs.onSurface)),
                              ]),
                              const SizedBox(height: 4),
                              Text('${item.recipe.price.toInt()} ${t('currency_suffix')}',
                                  style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _notesCtl(index, item.notes),
                                textAlign: TextAlign.right, textDirection: TextDirection.rtl,
                                decoration: InputDecoration(
                                  hintText: t('notes_hint'),
                                  hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.4), fontSize: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cs.outlineVariant)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cs.outlineVariant)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  isDense: true,
                                  filled: true, fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                                ),
                                style: TextStyle(fontSize: 12, color: cs.onSurface),
                                onChanged: (v) => context.read<OrderCubit>().updateNotes(index, v),
                              ),
                            ]),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('${item.totalPrice.toInt()} ${t('currency_suffix')}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
                          QuantitySelector(quantity: item.quantity,
                              onChanged: (d) => context.read<OrderCubit>().updateQuantity(index, d)),
                        ]),
                      ]),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(R.padding(context), 16, R.padding(context), 16),
              decoration: BoxDecoration(
                color: cs.surface,
                boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
                border: Border(top: BorderSide(color: cs.outlineVariant))),
              child: SafeArea(
                child: Column(children: [
                  TextField(
                    controller: _notesCtrl,
                    textAlign: TextAlign.right, textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: t('general_notes_hint'),
                      hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.outlineVariant)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.outlineVariant)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      filled: true, fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    SizedBox(height: 48, child: ElevatedButton(
                      onPressed: () { context.read<OrderCubit>().submitOrder(_notesCtrl.text); _notesCtrl.clear(); context.go('/kitchen'); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24)),
                      child: Row(children: [
                        const Icon(Icons.send_rounded, size: 18), const SizedBox(width: 8),
                        Text(t('send_order'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ]))),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${state.cartTotal.toInt()} ${t('currency_suffix')}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.primary)),
                      Text(t('total'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: cs.onSurfaceVariant)),
                    ]),
                  ]),
                ]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
