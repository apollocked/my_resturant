import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/domain/entities/cart_item.dart';
import 'package:my_resturant/presentation/cubits/order_cubit.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/shared/app_image.dart';
import 'package:my_resturant/presentation/widgets/order/quantity_selector.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final int index;
  final TextEditingController Function(String, String) notesCtl;
  final String notesHint;

  const CartItemCard({super.key, required this.item, required this.index, required this.notesCtl, required this.notesHint});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cubit = context.read<OrderCubit>();
    final suff = Tr.get('currency_suffix', context.watch<SettingsCubit>().state.locale);
    final screen = R.screenSize(context);
    final isDesktop = screen == ScreenSize.desktop;
    final isTablet = screen == ScreenSize.tablet;
    final imageSize = isDesktop ? 80.0 : isTablet ? 72.0 : 64.0;
    final nameSize = isDesktop ? 16 : isTablet ? 15 : 14;
    final priceSize = isDesktop ? 14 : isTablet ? 13 : 12;
    final totalSize = isDesktop ? 20 : isTablet ? 18 : 16;
    return Card(
      margin: EdgeInsets.only(bottom: isDesktop ? 14 : 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isDesktop ? 18 : 14)),
      child: Padding(
        padding: EdgeInsets.all(R.cardPadding(context)),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: AppImage(item.recipe.imageUrl, width: imageSize, height: imageSize)),
            SizedBox(width: isDesktop ? 18 : 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(children: [
                InkWell(onTap: () { HapticFeedback.mediumImpact(); cubit.removeFromCart(index); }, borderRadius: BorderRadius.circular(8),
                  child: Container(width: 32, height: 32, alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close, size: 16, color: AppColors.error))),
                const Spacer(),
                Text(item.recipe.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: nameSize, color: cs.onSurface)),
              ]),
              const SizedBox(height: 4),
Text('${item.recipe.price.toInt()} $suff',
    style: TextStyle(color: AppColors.primary, fontSize: priceSize, fontWeight: FontWeight.w600)),
              SizedBox(height: isDesktop ? 12 : 10),
              TextField(controller: notesCtl(item.recipe.id, item.notes), textAlign: TextAlign.right, textDirection: TextDirection.rtl,
                decoration: InputDecoration(hintText: notesHint,
                  hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.4), fontSize: isDesktop ? 13 : 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cs.outlineVariant)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cs.outlineVariant)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: isDesktop ? 12 : 10), isDense: true,
                  filled: true, fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3)),
                style: TextStyle(fontSize: isDesktop ? 13 : 12, color: cs.onSurface),
                onChanged: (v) => cubit.updateNotes(index, v)),
            ])),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
Text('${item.totalPrice.toInt()} $suff',
    style: TextStyle(fontWeight: FontWeight.w800, fontSize: totalSize, color: AppColors.primary)),
            QuantitySelector(quantity: item.quantity, onChanged: (d) => cubit.updateQuantity(index, d)),
          ]),
        ]),
      ),
    );
  }
}
