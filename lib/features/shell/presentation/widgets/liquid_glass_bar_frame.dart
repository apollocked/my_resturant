import 'package:flutter/material.dart';

import 'package:my_resturant/features/shell/presentation/widgets/liquid_glass_backdrop.dart';

/// The floating glass capsule around the nav dock.
///
/// Owns the dock's chrome: spring-driven entrance (slide + fade), the frosted
/// [LiquidGlassBackdrop], the outer shadow and the [Stack] that layers the
/// active chip below the tabs. The [LiquidGlassNavBar] state class only
/// supplies this frame with the entry [Animation], the accent and the slots.
class LiquidGlassBarFrame extends StatelessWidget {
  final Animation<double> entry;
  final Color accentColor;
  final bool dark;
  final int backdropGen;
  final List<Widget> slots;

  const LiquidGlassBarFrame({
    super.key,
    required this.entry,
    required this.accentColor,
    required this.dark,
    required this.backdropGen,
    required this.slots,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final cs = Theme.of(context).colorScheme;
    // Dark mode is a flat theme surface; light mode keeps a soft gradient.
    final bgTop = dark ? cs.surface : const Color(0xF2FDFBF8);
    final bgBottom = dark ? cs.surface : const Color(0xE6F2EDE6);
    // A whisper of the accent keeps light mode reading as living glass.
    final tintAmt = dark ? 0.0 : 0.035;
    final glassTop = Color.lerp(bgTop, accentColor, tintAmt)!;
    final glassBottom = Color.lerp(bgBottom, accentColor, tintAmt)!;
    final borderColor =
        dark ? const Color(0xFF2E2E2E) : Colors.black.withValues(alpha: 0.06);
    final shadow = cs.shadow.withValues(alpha: dark ? 0.45 : 0.14);
    const capsuleR = 17.0; // squared dock, same corner radius as the active pill
    const barH = 72.0;

    final slide = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end: Offset.zero,
    ).animate(entry);

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: entry,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            0,
            24,
            (bottomInset == 0 ? 10 : 6) + bottomInset,
          ),
          child: Container(
            height: barH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(capsuleR),
              boxShadow: [
                BoxShadow(
                  color: shadow,
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                  spreadRadius: -6,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(capsuleR),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LiquidGlassBackdrop(
                    top: glassTop,
                    bottom: glassBottom,
                    borderColor: borderColor,
                    backdropGen: backdropGen,
                  ),
                  ...slots,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}