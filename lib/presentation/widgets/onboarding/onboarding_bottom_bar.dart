import 'package:flutter/material.dart';
import 'package:my_resturant/presentation/pages/onboarding/onb_colors.dart';
import 'package:my_resturant/presentation/widgets/shared/pressable_scale.dart';

class OnboardingBottomBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final Color accent;
  final VoidCallback onNext;
  final String label;

  const OnboardingBottomBar({super.key, required this.page, required this.totalPages, required this.accent, required this.onNext, required this.label});

  @override
  Widget build(BuildContext context) {
    final ob = OnbColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Row(
        children: [
          ...List.generate(totalPages, (i) {
            final active = page == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic,
              margin: const EdgeInsets.only(right: 6),
              width: active ? 32 : 10, height: 10,
              decoration: BoxDecoration(
                gradient: active ? LinearGradient(colors: [accent, accent.withValues(alpha: 0.6)]) : null,
                color: active ? null : ob.dotInactive,
                borderRadius: BorderRadius.circular(5),
              ),
            );
          }),
          const Spacer(),
          PressableScale(
            onTap: onNext,
            child: Container(
              height: 54, padding: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [accent, accent.withValues(alpha: 0.75)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: accent.withValues(alpha: ob.ctaShadow), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.3)),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
