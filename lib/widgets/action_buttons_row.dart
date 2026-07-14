import 'package:flutter/material.dart';
import 'package:my_resturant/main.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback? onAddSection, onAddFood;
  const ActionButtonsRow({super.key, this.onAddSection, this.onAddFood});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
      Expanded(child: SizedBox(height: 44, child: OutlinedButton(
        onPressed: onAddSection,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primary, side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add, size: 18), SizedBox(width: 6),
          Text('بەش', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ])))), 
      const SizedBox(width: 10),
      Expanded(child: SizedBox(height: 44, child: ElevatedButton(
        onPressed: onAddFood,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add, size: 18), SizedBox(width: 6),
          Text('خواردن', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ])))), 
    ]));
  }
}
