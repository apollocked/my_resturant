import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_resturant/viewmodels/order_viewmodel.dart';

class HeaderWidget extends StatelessWidget {
  final VoidCallback? onShoppingBagTap;
  final VoidCallback? onNotificationTap;

  const HeaderWidget({
    super.key,
    this.onShoppingBagTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<OrderViewModel>().cartCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black87),
                onPressed: onNotificationTap,
              ),
            ),
            Positioned(
              top: 9, right: 9,
              child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF2EC153), shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        const Text('ڕێستۆرانتەکەم',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black54)),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black87, size: 26),
              onPressed: onShoppingBagTap,
            ),
            if (cartCount > 0)
              Positioned(
                top: 6, right: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2EC153), shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text('$cartCount', textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
