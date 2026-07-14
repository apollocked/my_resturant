import 'package:flutter/material.dart';
import 'package:my_resturant/main.dart';

class TableSelector extends StatelessWidget {
  final int selectedTable;
  final ValueChanged<int> onChanged;

  const TableSelector({super.key, required this.selectedTable, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPicker(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primarySoft, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('مێز $selectedTable',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primary)),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more, color: AppTheme.primary, size: 18),
        ]),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        const Text('هەڵبژاردنی مێز', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        Wrap(spacing: 10, runSpacing: 10, children: List.generate(20, (i) {
          final n = i + 1;
          final sel = n == selectedTable;
          return SizedBox(width: 56, height: 44, child: OutlinedButton(
            onPressed: () { onChanged(n); Navigator.pop(ctx); },
            style: OutlinedButton.styleFrom(
              backgroundColor: sel ? AppTheme.primary : Colors.white,
              foregroundColor: sel ? Colors.white : AppTheme.textPrimary,
              side: BorderSide(color: sel ? AppTheme.primary : const Color(0xFFE0DCD8)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('$n', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ));
        })),
        const SizedBox(height: 12),
      ])),
    );
  }
}
