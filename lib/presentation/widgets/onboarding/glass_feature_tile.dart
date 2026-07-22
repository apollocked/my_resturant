import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/pages/onboarding/onb_colors.dart';

class GlassFeatureTile extends StatelessWidget {
  final String label;
  final Color accent;
  final OnbColors ob;
  const GlassFeatureTile({super.key, required this.label, required this.accent, required this.ob});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(color: ob.glassBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: ob.glassBorder)),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: ob.checkBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.check_rounded, size: 22, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: TextStyle(fontSize: R.fontMd(context), fontWeight: FontWeight.w600, color: ob.textPrimary))),
            ],
          ),
        ),
      ),
    );
  }
}
