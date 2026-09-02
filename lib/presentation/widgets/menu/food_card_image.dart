import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/presentation/widgets/menu/food_card_notes_badge.dart';
import 'package:my_resturant/presentation/widgets/menu/food_card_price_badge.dart';
import 'package:my_resturant/presentation/widgets/menu/food_card_qty_badge.dart';
import 'package:my_resturant/presentation/widgets/menu/food_card_remove_button.dart';
import 'package:my_resturant/shared/app_image.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class FoodCardImage extends StatelessWidget {
  final Recipe recipe;
  final int quantity;
  final String notes;
  final VoidCallback? onTap, onLongPress, onRemove;

  const FoodCardImage({
    super.key,
    required this.recipe,
    required this.quantity,
    required this.notes,
    this.onTap,
    this.onLongPress,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    final cs = Theme.of(context).colorScheme;
    final screen = R.screenSize(context);
    final isDesktop = screen == ScreenSize.desktop;
    final isTablet = screen == ScreenSize.tablet;
    final isSelected = quantity > 0;
    final pricePadH = isDesktop
        ? 14.0
        : isTablet
        ? 12.0
        : 10.0;
    final pricePadV = isDesktop
        ? 8.0
        : isTablet
        ? 6.0
        : 5.0;
    final priceFontSize = isDesktop
        ? 15.0
        : isTablet
        ? 13.0
        : 12.0;
    final badgeSize = isDesktop
        ? 48.0
        : isTablet
        ? 42.0
        : 36.0;
    final badgeFontSize = isDesktop
        ? 18.0
        : isTablet
        ? 16.0
        : 14.0;
    final notesIconSize = isDesktop
        ? 22.0
        : isTablet
        ? 18.0
        : 16.0;
    String t(String key) => Tr.get(key, settings.state.locale);
    return Expanded(
      child: PressableScale(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'meal-img-${recipe.imageUrl}',
                child: AppImage(recipe.imageUrl, width: double.infinity),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          cs.shadow.withValues(alpha: 0.35),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              FoodCardPriceBadge(
                label: '${recipe.price.toInt()} ${t('currency_suffix')}',
                cs: cs,
                padH: pricePadH,
                padV: pricePadV,
                fontSize: priceFontSize,
              ),
              if (isSelected)
                FoodCardQtyBadge(
                  quantity: quantity,
                  cs: cs,
                  size: badgeSize,
                  fontSize: badgeFontSize,
                ),
              if (isSelected && onRemove != null)
                FoodCardRemoveButton(
                  label: t('delete'),
                  cs: cs,
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                  onRemove: () => onRemove?.call(),
                ),
              if (notes.isNotEmpty)
                FoodCardNotesBadge(cs: cs, size: notesIconSize),
            ],
          ),
        ),
      ),
    );
  }
}
