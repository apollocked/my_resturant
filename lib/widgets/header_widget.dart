import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/viewmodels/order_viewmodel.dart';

class HeaderWidget extends StatelessWidget {
  final VoidCallback? onShoppingBagTap;
  const HeaderWidget({super.key, this.onShoppingBagTap});

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<OrderViewModel>().cartCount;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Stack(clipBehavior: Clip.none, children: [
        IconButton(icon: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary, size: 24), onPressed: () {}),
        Positioned(top: 8, right: 8, child: Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5)))),
      ]),
      Text('ڕێستۆرانتەکەم', style: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary.withValues(alpha: 0.85))),
      Stack(clipBehavior: Clip.none, children: [
        IconButton(icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.textPrimary, size: 24),
            onPressed: onShoppingBagTap),
        if (cartCount > 0)
          Positioned(top: 6, right: 6, child: Container(
            width: 18, height: 18, alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5)),
            child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
      ]),
    ]);
  }
}
