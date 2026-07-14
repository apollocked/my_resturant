import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/widgets/app_image.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class FoodCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onIncrement, onDecrement, onLongPress;
  final int quantity;
  final String notes;

  const FoodCard({super.key, required this.recipe, this.onIncrement, this.onDecrement, this.onLongPress,
    this.quantity = 0, this.notes = ''});

  @override
  Widget build(BuildContext context) {
    final isSelected = quantity > 0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0), duration: const Duration(milliseconds: 300), curve: Curves.easeOut,
      builder: (context, scale, _) => Transform.scale(scale: scale, child: _card(context, isSelected)));
  }

  Widget _card(BuildContext context, bool isSelected) {
    final settings = context.watch<SettingsCubit>();
    final cs = Theme.of(context).colorScheme;
    final isTablet = R.isTablet(context);
    final cp = isTablet ? 16.0 : 12.0;
    String t(String key) => Tr.get(key, settings.state.locale);
    return GestureDetector(
      onTap: onIncrement, onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface, borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
          boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6))]),
        clipBehavior: Clip.hardEdge,
        child: Column(children: [
          AspectRatio(aspectRatio: isTablet ? 1.4 : 1.2,
            child: Stack(fit: StackFit.expand, children: [
              AppImage(recipe.imageUrl, width: double.infinity),
              Positioned.fill(child: IgnorePointer(child: Container(
                decoration: BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, cs.shadow.withValues(alpha: 0.35)], stops: const [0.5, 1.0]))))),
              Positioned(top: 10, right: 10, child: Container(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 10, vertical: isTablet ? 6 : 5),
                decoration: BoxDecoration(color: cs.surface.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)),
                child: Text('${recipe.price.toInt()} ${t('currency_suffix')}',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTablet ? 13 : 12, color: cs.onSurface)))),
              if (isSelected)
                Positioned(top: 10, left: 10, child: Container(
                  width: isTablet ? 32 : 28, height: isTablet ? 32 : 28, alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8)]),
                  child: Text('$quantity', style: TextStyle(color: Colors.white, fontSize: isTablet ? 13 : 12, fontWeight: FontWeight.bold)))),
              if (notes.isNotEmpty)
                Positioned(bottom: 10, left: 10, child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: cs.surface.withValues(alpha: 0.85), shape: BoxShape.circle),
                  child: Icon(Icons.edit_note, size: isTablet ? 18 : 16, color: AppColors.primary))),
            ]),
          ),
          Padding(padding: EdgeInsets.fromLTRB(cp, isTablet ? 12 : 10, cp, cp),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(recipe.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: isTablet ? 15 : 13, color: cs.onSurface)),
              const SizedBox(height: 3),
              Text(recipe.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: isTablet ? 12 : 11)),
              SizedBox(height: isTablet ? 14 : 10),
              if (isSelected)
                Column(children: [
                  Container(height: isTablet ? 44 : 38,
                    decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(isTablet ? 14 : 12)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      InkWell(onTap: onDecrement, borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                        child: Container(width: isTablet ? 46 : 38, alignment: Alignment.center,
                            child: Icon(Icons.remove, size: isTablet ? 22 : 20, color: AppColors.primary))),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isTablet ? 10 : 6),
                        decoration: BoxDecoration(border: Border.symmetric(
                            vertical: BorderSide(color: cs.outlineVariant, width: 1))),
                        child: Text('$quantity', style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTablet ? 17 : 15, color: AppColors.primary))),
                      InkWell(onTap: onIncrement, borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                        child: Container(width: isTablet ? 46 : 38, alignment: Alignment.center,
                            child: Icon(Icons.add, size: isTablet ? 22 : 20, color: AppColors.primary))),
                    ]),
                  ),
                  SizedBox(height: isTablet ? 8 : 6),
                  Text('${(recipe.price * quantity).toInt()} ${t('currency_suffix')}',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTablet ? 15 : 13, color: AppColors.primary)),
                ])
              else
                SizedBox(width: double.infinity, height: isTablet ? 44 : 38,
                  child: ElevatedButton(onPressed: onIncrement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isTablet ? 14 : 12)),
                      elevation: 0, padding: EdgeInsets.zero),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add, size: isTablet ? 20 : 18), const SizedBox(width: 6),
                      Text(t('add'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: isTablet ? 15 : 13)),
                    ]))),
            ]),
          ),
        ]),
      ),
    );
  }
}
