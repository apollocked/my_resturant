import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(-1);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
              child: Icon(Icons.remove, size: 20, color: cs.onSurface),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: cs.outlineVariant, width: 1),
              ),
            ),
            child: Text(
              '$quantity',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          InkWell(
            onTap: quantity < 99
                ? () {
                    HapticFeedback.lightImpact();
                    onChanged(1);
                  }
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Icon(
                Icons.add,
                size: 20,
                color: quantity < 99 ? cs.onSurface : cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
