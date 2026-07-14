import 'package:flutter/material.dart';
import 'package:my_resturant/theme/app_theme.dart';

class MenuHero extends StatelessWidget {
  const MenuHero({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0), height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18), color: AppTheme.primary,
        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))]),
      clipBehavior: Clip.hardEdge,
      child: Stack(children: [
        Positioned(right: -30, top: -30, child: Container(width: 160, height: 160,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle))),
        Positioned(left: -20, bottom: -20, child: Container(width: 120, height: 120,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), shape: BoxShape.circle))),
        Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('بەخێربێیت بۆ ڕێستۆرانتەکەم',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('داوای خواردنی خوازەکەت بکە', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
        ])),
        Positioned(left: 16, bottom: 16, child: Icon(Icons.restaurant_menu,
            color: Colors.white.withValues(alpha: 0.15), size: 60)),
      ]),
    );
  }
}
