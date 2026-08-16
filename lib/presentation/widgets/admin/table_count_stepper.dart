import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class TableCountStepper extends StatelessWidget {
  const TableCountStepper({
    super.key,
    required this.count,
    required this.isDesktop,
    required this.cs,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int count;
  final bool isDesktop;
  final ColorScheme cs;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  Widget _countBtn(IconData icon, VoidCallback onTap) {
    final size = isDesktop ? 52.0 : 44.0;
    return PressableScale(
      onTap: onTap,
      child: Material(
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        ),
        elevation: 0,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: isDesktop ? 26 : 22,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.padding(context)),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _countBtn(Icons.remove, onDecrement),
          Container(
            width: isDesktop ? 100 : 80,
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: R.fontXxl(context),
                color: cs.onSurface,
              ),
            ),
          ),
          _countBtn(Icons.add, onIncrement),
        ],
      ),
    );
  }
}
