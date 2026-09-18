import 'package:flutter/material.dart';

/// Paper width choice chips for the printer (58 mm / 80 mm).
class PrinterPaperSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const PrinterPaperSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [58, 80].map((w) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: ChoiceChip(
            label: Text('${w}mm'),
            selected: value == w,
            onSelected: (_) => onChanged(w),
            selectedColor: cs.primary.withValues(alpha: 0.15),
          ),
        );
      }).toList(),
    );
  }
}