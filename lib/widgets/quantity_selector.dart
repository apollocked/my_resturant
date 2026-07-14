import 'package:flutter/material.dart';
import 'package:my_resturant/theme/app_theme.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const QuantitySelector({super.key, required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF5F4F2), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        InkWell(onTap: () => onChanged(-1), borderRadius: BorderRadius.circular(8),
          child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.remove, size: 16, color: AppTheme.textPrimary))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
        InkWell(onTap: quantity < 99 ? () => onChanged(1) : null, borderRadius: BorderRadius.circular(8),
          child: Padding(padding: const EdgeInsets.all(6),
              child: Icon(Icons.add, size: 16, color: quantity < 99 ? AppTheme.textPrimary : Colors.grey))),
      ]),
    );
  }
}
