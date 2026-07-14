import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

class ImagePickerButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ImagePickerButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.wallpaper, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
