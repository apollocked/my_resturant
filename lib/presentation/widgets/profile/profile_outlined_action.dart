import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

class ProfileOutlinedAction extends StatelessWidget {
  const ProfileOutlinedAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
    this.sideWidth = 1.0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final double sideWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PressableScale(
        onTap: onTap,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            disabledForegroundColor: color,
            side: BorderSide(color: color, width: sideWidth),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      ),
    );
  }
}
