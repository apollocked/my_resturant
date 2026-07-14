import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/presentation/cubits/settings_cubit.dart';
import 'package:my_resturant/core/l10n/tr.dart';
import 'package:my_resturant/domain/entities/recipe.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/presentation/widgets/shared/app_image.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class FoodCardImage extends StatelessWidget {
  final Recipe recipe;
  final int quantity;
  final String notes;
  final VoidCallback? onTap, onLongPress;

  const FoodCardImage({super.key, required this.recipe, required this.quantity, required this.notes, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    final cs = Theme.of(context).colorScheme;
    final isTablet = R.isTablet(context);
    final isSelected = quantity > 0;
    String t(String key) => Tr.get(key, settings.state.locale);
    return Expanded(
      child: GestureDetector(
        onTap: onTap, onLongPress: onLongPress,
        child: Stack(fit: StackFit.expand, children: [
          AppImage(recipe.imageUrl, width: double.infinity),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, cs.shadow.withValues(alpha: 0.35)],
                stops: const [0.5, 1.0],
              ))),
            ),
          ),
          Positioned(top: 10, right: 10, child: Container(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 10, vertical: isTablet ? 6 : 5),
            decoration: BoxDecoration(color: cs.surface.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)),
            child: Text('${recipe.price.toInt()} ${t('currency_suffix')}',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTablet ? 13 : 12, color: cs.onSurface)),
          )),
          if (isSelected)
            Positioned(top: 10, left: 10, child: Container(
              width: isTablet ? 42 : 36, height: isTablet ? 42 : 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Text('$quantity',
                  style: TextStyle(color: Colors.white, fontSize: isTablet ? 16 : 14, fontWeight: FontWeight.bold)),
            )),
          if (notes.isNotEmpty)
            Positioned(bottom: 10, left: 10, child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: cs.surface.withValues(alpha: 0.85), shape: BoxShape.circle),
              child: Icon(Icons.edit_note, size: isTablet ? 18 : 16, color: AppColors.primary),
            )),
        ]),
      ),
    );
  }
}
