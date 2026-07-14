import 'package:flutter/material.dart';
import 'package:my_resturant/models/recipe.dart';
import 'package:my_resturant/theme/app_theme.dart';
import 'package:my_resturant/widgets/app_image.dart';

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
    return GestureDetector(
      onTap: onIncrement, onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: isSelected ? Border.all(color: AppTheme.primary, width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))]),
        clipBehavior: Clip.hardEdge,
        child: Column(children: [
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              AppImage(recipe.imageUrl, width: double.infinity),
              Positioned.fill(child: IgnorePointer(child: Container(
                decoration: BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)], stops: const [0.6, 1.0]))))),
              Positioned(top: 8, right: 8, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(6)),
                child: Text('${recipe.price.toInt()} د.ع', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)))),
              if (isSelected)
                Positioned(top: 8, left: 8, child: Container(
                  width: 26, height: 26, alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                  child: Text('$quantity', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
              if (notes.isNotEmpty)
                Positioned(bottom: 8, left: 8, child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
                  child: const Icon(Icons.edit_note, size: 14, color: Colors.white))),
            ]),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(recipe.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text(recipe.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
              const SizedBox(height: 6),
              if (isSelected)
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      InkWell(onTap: onDecrement, child: const Padding(padding: EdgeInsets.all(5),
                          child: Icon(Icons.remove, size: 14, color: AppTheme.primary))),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primary))),
                      InkWell(onTap: onIncrement, child: const Padding(padding: EdgeInsets.all(5),
                          child: Icon(Icons.add, size: 14, color: AppTheme.primary))),
                    ]),
                  ),
                  Text('${(recipe.price * quantity).toInt()} د.ع',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.primary)),
                ])
              else
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const SizedBox(),
                  Text('${recipe.price.toInt()} د.ع',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textSecondary)),
                ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
