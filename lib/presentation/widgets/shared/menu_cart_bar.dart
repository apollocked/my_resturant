import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class MenuCartBar extends StatelessWidget {
  final int cartCount;
  final int cartTotal;
  final VoidCallback? onViewCart;
  const MenuCartBar({super.key, required this.cartCount, required this.cartTotal, this.onViewCart});
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    final cs = Theme.of(context).colorScheme;
    final isDesktop = R.isDesktop(context);
    String t(String key) => Tr.get(key, settings.state.locale);
    return Container(
      padding: EdgeInsets.fromLTRB(R.padding(context), isDesktop ? 16 : 12, R.padding(context), isDesktop ? 16 : 12),
      decoration: BoxDecoration(color: cs.surface,
        boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
        border: Border(top: BorderSide(color: cs.outlineVariant))),
      child: SafeArea(child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${cartTotal.toInt()} ${t('currency_suffix')}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: isDesktop ? 22 : 18, color: AppColors.primary)),
          Text(t('items').replaceAll('{count}', '$cartCount'), style: TextStyle(fontSize: isDesktop ? 13 : 11, color: cs.onSurfaceVariant)),
        ])),
        SizedBox(width: isDesktop ? 24 : 16),
        SizedBox(height: isDesktop ? 52 : 46, child: ElevatedButton(
          onPressed: onViewCart,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isDesktop ? 16 : 12)),
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 20),
          ),
          child: Row(children: [
            Icon(Icons.shopping_bag, size: isDesktop ? 22 : 18), SizedBox(width: isDesktop ? 10 : 6),
            Text(t('view_order'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: isDesktop ? 16 : 13)),
          ]),
        )),
      ])),
    );
  }
}
