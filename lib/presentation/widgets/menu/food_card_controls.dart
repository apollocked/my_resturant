import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class FoodCardControls extends StatelessWidget {
  final int quantity;
  final double totalPrice;
  final VoidCallback? onIncrement, onDecrement;

  const FoodCardControls({super.key, required this.quantity, required this.totalPrice, this.onIncrement, this.onDecrement});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    final cs = Theme.of(context).colorScheme;
    final isTablet = R.isTablet(context);
    final btnW = isTablet ? 64.0 : 52.0;
    final gap = isTablet ? 28.0 : 16.0;
    String t(String key) => Tr.get(key, settings.state.locale);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (quantity > 0)
        Column(mainAxisSize: MainAxisSize.min, children: [
          FittedBox(child: Row(mainAxisSize: MainAxisSize.min, children: [
            InkWell(onTap: onDecrement, borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
              child: Container(width: btnW, height: isTablet ? 28 : 25, alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.primary,
                  borderRadius: BorderRadius.circular(isTablet ? 14 : 12)),
                child: Icon(Icons.remove, size: isTablet ? 22 : 20, color: Colors.white))),
            SizedBox(width: gap),
            Text('$quantity', style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTablet ? 17 : 15, color: AppColors.primary)),
            SizedBox(width: gap),
            InkWell(onTap: onIncrement, borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
              child: Container(width: btnW, height: isTablet ? 28 : 25, alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.primary,
                  borderRadius: BorderRadius.circular(isTablet ? 14 : 12)),
                child: Icon(Icons.add, size: isTablet ? 22 : 20, color: Colors.white))),
          ])),
          SizedBox(height: isTablet ? 8 : 6),
          Text('${totalPrice.toInt()} ${t('currency_suffix')}',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTablet ? 15 : 13, color: AppColors.primary)),
        ])
      else
        SizedBox(width: double.infinity, height: isTablet ? 44 : 38,
          child: ElevatedButton(onPressed: onIncrement,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: cs.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isTablet ? 14 : 12)),
              elevation: 0, padding: EdgeInsets.zero,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add, size: isTablet ? 20 : 18),
              const SizedBox(width: 6),
              Text(t('add'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: isTablet ? 15 : 13)),
            ]))),
    ]);
  }
}
