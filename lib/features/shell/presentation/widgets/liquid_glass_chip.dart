import 'package:flutter/material.dart';

/// The animated active-tab indicator of [LiquidGlassNavBar].
///
/// A squircled tonal pill that glides between tabs on the shared spring-driven
/// [anim] controller. It narrows mid-flight, then swells and settles with a
/// soft glow. Kept in its own file so the nav bar stays a thin composition.
class LiquidGlassChip extends StatelessWidget {
  /// Identifies the sliding active indicator in tests.
  static const Key navChipKey = ValueKey('liquid-nav-chip');

  final Animation<double> anim;
  final int itemCount;
  final Color accent;
  final bool dark;

  const LiquidGlassChip({
    super.key,
    required this.anim,
    required this.itemCount,
    required this.accent,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final n = itemCount;
            final tabW = constraints.maxWidth / n;
            // The active indicator wraps the icon AND the label but keeps a
            // breath of cell on each side. It narrows in flight, then swolels
            // out on land.
            const landedH = 48.0;
            const pillR = 17.0;
            const pillCY = 36.0; // bar mid-height (72 / 2)
            const landedFrac = 0.86; // seated width of the cell
            const flightFrac = 0.60; // mid-flight width factor
            return IgnorePointer(
              child: AnimatedBuilder(
                animation: anim,
                builder: (context, _) {
                  final t = anim.value.clamp(0, n - 1).toDouble();
                  final center = t.round().clamp(0, n - 1);
                  final dist = (t - center).abs();
                  final travel = Curves.easeInOut.transform(
                    (dist * 2).clamp(0.0, 1.0),
                  );
                  final landedness = 1.0 - travel;
                  final landedW = tabW * landedFrac;
                  final w =
                      landedW * (1 - (1 - flightFrac) * travel);
                  final h = landedH - 8 * travel;
                  final lift = 2.5 * travel;
                  final start = tabW * (t + 0.5) - w / 2;
                  final top = pillCY - h / 2 - lift;
                  final glowW = w;
                  final glowH = h + 16;
                  final glowTop = pillCY - glowH / 2 - lift;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Ambient glow behind the active pill.
                      PositionedDirectional(
                        start: start,
                        top: glowTop,
                        width: glowW,
                        height: glowH,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(glowH / 2),
                            gradient: RadialGradient(
                              colors: [
                                accent.withValues(
                                  alpha: (dark ? 0.11 : 0.06) * landedness,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Active cell wrapper: covers icon + label.
                      PositionedDirectional(
                        key: navChipKey,
                        start: start,
                        top: top,
                        width: w,
                        height: h,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(pillR),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                accent.withValues(
                                  alpha: dark ? 0.32 : 0.26,
                                ),
                                accent.withValues(
                                  alpha: dark ? 0.14 : 0.10,
                                ),
                              ],
                            ),
                            border: Border.all(
                              color: accent.withValues(
                                alpha: dark ? 0.40 : 0.34,
                              ),
                              width: 1,
                            ),
                          ),
                          // Glass inner highlight.
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(pillR - 1),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(
                                    alpha: dark ? 0.18 : 0.26,
                                  ),
                                  Colors.transparent,
                                  Colors.black.withValues(
                                    alpha: dark ? 0.10 : 0.04,
                                  ),
                                ],
                                stops: const [0, 0.42, 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}