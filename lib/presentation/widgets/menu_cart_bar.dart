import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class MenuCartBar extends StatelessWidget {
  final int cartCount;
  final int cartTotal;
  final VoidCallback? onViewCart;
  const MenuCartBar({super.key, required this.cartCount, required this.cartTotal, this.onViewCart});
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    final cs = Theme.of(context).colorScheme;
    String t(String key) => Tr.get(key, settings.state.locale);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(color: cs.surface,
        boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
        border: Border(top: BorderSide(color: cs.outlineVariant))),
      child: SafeArea(child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${cartTotal.toInt()} ${t('currency_suffix')}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary)),
          Text(t('items').replaceAll('{count}', '$cartCount'), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        const SizedBox(width: 16),
        SizedBox(height: 46, child: ElevatedButton(
          onPressed: onViewCart,
          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Row(children: [
            const Icon(Icons.shopping_bag, size: 18), const SizedBox(width: 6),
            Text(t('view_order'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        )),
      ])),
    );
  }
}
