import 'package:flutter/material.dart';
import 'package:my_resturant/main.dart';

class MenuCartBar extends StatelessWidget {
  final int cartCount;
  final int cartTotal;
  final VoidCallback? onViewCart;
  const MenuCartBar({super.key, required this.cartCount, required this.cartTotal, this.onViewCart});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
        border: const Border(top: BorderSide(color: Color(0xFFF0EDEA)))),
      child: SafeArea(child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${cartTotal.toInt()} د.ع', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.primary)),
          Text('$cartCount دانە', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ])),
        const SizedBox(width: 16),
        SizedBox(height: 46, child: ElevatedButton(
          onPressed: onViewCart,
          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Row(children: [
            Icon(Icons.shopping_bag, size: 18), SizedBox(width: 6),
            Text('سەیرکردنی داواکاری', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        )),
      ])),
    );
  }
}
