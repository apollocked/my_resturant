import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/presentation/pages/onboarding/onb_colors.dart';
import 'package:my_resturant/shared/pressable_scale.dart';

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
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Row(
        children: [
          ...List.generate(totalPages, (i) {
            final active = page == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic,
              margin: const EdgeInsetsDirectional.only(end: 6),
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
                  Text(label, style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w700, fontSize: R.fontMd(context), letterSpacing: 0.3)),
                  const SizedBox(width: 10),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Icon(
                      _isRtl(context)
                          ? Icons.arrow_back
                          : Icons.arrow_forward,
                      color: cs.onPrimary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isRtl(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode;
    return lc == 'ar' || lc == 'ku';
  }
}
