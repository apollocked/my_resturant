import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final screen = R.screenSize(context);
    final isDesktop = screen == ScreenSize.desktop;
    final isTablet = screen == ScreenSize.tablet;
    final btnW = isDesktop ? 72.0 : isTablet ? 64.0 : 52.0;
    final btnH = isDesktop ? 32.0 : isTablet ? 28.0 : 25.0;
    final gap = isDesktop ? 36.0 : isTablet ? 28.0 : 16.0;
    final iconSize = isDesktop ? 26 : isTablet ? 22 : 20;
    final qtyFont = isDesktop ? 20.0 : isTablet ? 17.0 : 15.0;
    final totalFont = isDesktop ? 17.0 : isTablet ? 15.0 : 13.0;
    final btnRadius = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;
    final addBtnH = isDesktop ? 50.0 : isTablet ? 44.0 : 38.0;
    final addFont = isDesktop ? 16.0 : isTablet ? 15.0 : 13.0;
    final addIcon = isDesktop ? 22 : isTablet ? 20 : 18;
    String t(String key) => Tr.get(key, settings.state.locale);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (quantity > 0)
        Column(mainAxisSize: MainAxisSize.min, children: [
          FittedBox(child: Row(mainAxisSize: MainAxisSize.min, children: [
            InkWell(onTap: () { HapticFeedback.lightImpact(); onDecrement?.call(); }, borderRadius: BorderRadius.circular(btnRadius),
              child: Container(width: btnW, height: btnH, alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.primary,
                  borderRadius: BorderRadius.circular(btnRadius)),
                child: Icon(Icons.remove, size: iconSize, color: cs.onPrimary))),
            SizedBox(width: gap),
            Text('$quantity', style: TextStyle(fontWeight: FontWeight.w800, fontSize: qtyFont, color: AppColors.primary)),
            SizedBox(width: gap),
            InkWell(onTap: () { HapticFeedback.lightImpact(); onIncrement?.call(); }, borderRadius: BorderRadius.circular(btnRadius),
              child: Container(width: btnW, height: btnH, alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.primary,
                  borderRadius: BorderRadius.circular(btnRadius)),
                child: Icon(Icons.add, size: iconSize, color: cs.onPrimary))),
          ])),
          SizedBox(height: isDesktop ? 10 : isTablet ? 8 : 6),
          Text('${totalPrice.toInt()} ${t('currency_suffix')}',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: totalFont, color: AppColors.primary)),
        ])
      else
        SizedBox(width: double.infinity, height: addBtnH,
          child: ElevatedButton(onPressed: () { HapticFeedback.lightImpact(); onIncrement?.call(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: cs.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(btnRadius)),
              elevation: 0, padding: EdgeInsets.zero,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add, size: addIcon),
              const SizedBox(width: 6),
              Text(t('add'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: addFont)),
            ]))),
    ]);
  }
}
