import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class FoodCardRemoveButton extends StatelessWidget {
  const FoodCardRemoveButton({
    super.key,
    required this.label,
    required this.cs,
    required this.isDesktop,
    required this.isTablet,
    required this.onRemove,
  });

  final String label;
  final ColorScheme cs;
  final bool isDesktop;
  final bool isTablet;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 10,
      child: PressableScale(
        onTap: () {
          HapticFeedback.mediumImpact();
          onRemove();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop
                ? 12
                : isTablet
                ? 10
                : 8,
            vertical: isDesktop
                ? 7
                : isTablet
                ? 6
                : 5,
          ),
          decoration: BoxDecoration(
            color: cs.error,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: cs.error.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: isDesktop
                    ? 16
                    : isTablet
                    ? 14
                    : 13,
                color: cs.onError,
              ),
              SizedBox(width: isDesktop ? 5 : 4),
              Text(
                label,
                style: TextStyle(
                  color: cs.onError,
                  fontSize: isDesktop
                      ? 12
                      : isTablet
                      ? 11
                      : 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
