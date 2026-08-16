import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/menu/food_card_add_button.dart';
import 'package:my_resturant/presentation/widgets/menu/food_card_stepper.dart';

class FoodCardControls extends StatelessWidget {
  final int quantity;
  final double totalPrice;
  final VoidCallback? onIncrement, onDecrement;

  const FoodCardControls({
    super.key,
    required this.quantity,
    required this.totalPrice,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    final cs = Theme.of(context).colorScheme;
    final screen = R.screenSize(context);
    final isDesktop = screen == ScreenSize.desktop;
    final isTablet = screen == ScreenSize.tablet;
    final btnW = isDesktop
        ? 72.0
        : isTablet
        ? 64.0
        : 52.0;
    final btnH = isDesktop
        ? 32.0
        : isTablet
        ? 28.0
        : 25.0;
    final gap = isDesktop
        ? 36.0
        : isTablet
        ? 28.0
        : 16.0;
    final iconSize = isDesktop
        ? 26.0
        : isTablet
        ? 22.0
        : 20.0;
    final qtyFont = isDesktop
        ? 20.0
        : isTablet
        ? 17.0
        : 15.0;
    final totalFont = isDesktop
        ? 17.0
        : isTablet
        ? 15.0
        : 13.0;
    final btnRadius = isDesktop
        ? 16.0
        : isTablet
        ? 14.0
        : 12.0;
    final addBtnH = isDesktop
        ? 50.0
        : isTablet
        ? 44.0
        : 38.0;
    final addFont = isDesktop
        ? 16.0
        : isTablet
        ? 15.0
        : 13.0;
    final addIcon = isDesktop
        ? 22.0
        : isTablet
        ? 20.0
        : 18.0;
    String t(String key) => Tr.get(key, settings.state.locale);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (quantity > 0)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FoodCardStepper(
                quantity: quantity,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
                cs: cs,
                btnW: btnW,
                btnH: btnH,
                btnRadius: btnRadius,
                iconSize: iconSize,
                qtyFont: qtyFont,
                gap: gap,
              ),
              SizedBox(
                height: isDesktop
                    ? 10
                    : isTablet
                    ? 8
                    : 6,
              ),
              Text(
                '${totalPrice.toInt()} ${t('currency_suffix')}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: totalFont,
                  color: AppColors.primary,
                ),
              ),
            ],
          )
        else
          FoodCardAddButton(
            label: t('add'),
            onAdd: onIncrement,
            cs: cs,
            height: addBtnH,
            fontSize: addFont,
            iconSize: addIcon,
            radius: btnRadius,
          ),
      ],
    );
  }
}
