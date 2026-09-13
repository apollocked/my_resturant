import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/liquid_nav_item.dart';
import 'package:my_resturant/shared/liquid_nav_shine.dart';
import 'package:my_resturant/shared/liquid_nav_tab.dart';

/// A 2026-style floating "aurora glass dock".
///
/// A capsule-shaped frosted dock that floats above the content. The active
/// tab is marked by a morphing aurora pill that glides between tabs while
/// "breathing": it narrows as it travels and swells as it lands, giving a
/// liquid, gravity-weighted feel. Ambient color blooms live inside the glass
/// so the dock reads tonal even before page content blurs through, and the
/// whole dock rises in on first mount.
class LiquidGlassNavBar extends StatefulWidget {
  final List<LiquidNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final int? badgeCount;
  final int? badgeIndex;
  final Color accentColor;
  final bool isDark;
  const LiquidGlassNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.badgeCount,
    this.badgeIndex,
    this.accentColor = AppColors.primary,
    this.isDark = true,
  });
  @override
  State<LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<LiquidGlassNavBar>
    with TickerProviderStateMixin {
  late final AnimationController _ctl;
  late final AnimationController _entryCtl;

  /// Bumped on every tab change so the glass backdrop re-captures the page
  /// behind the dock (kept isolated from the moving pill, whose animation
  /// state stays untouched).
  int _backdropGen = 0;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    )..value = widget.selectedIndex.toDouble();
    _entryCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassNavBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      _backdropGen++;
      _ctl.animateTo(
        widget.selectedIndex.toDouble(),
        curve: Curves.easeOutBack,
      );
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    _entryCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final cs = Theme.of(context).colorScheme;
    final dark = widget.isDark;
    final accent = widget.accentColor;
    final sel = accent;
    final unsel = dark
        ? Colors.white.withValues(alpha: 0.62)
        : cs.onSurface.withValues(alpha: 0.5);
    final bgColor = dark ? const Color(0xEC171726) : const Color(0xB3F7F8FB);
    final borderColor = dark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.6);
    final shadowColor = cs.shadow.withValues(alpha: dark ? 0.6 : 0.18);
    final glowColor = accent.withValues(alpha: dark ? 0.24 : 0.12);
    final haloColor = accent.withValues(alpha: dark ? 0.45 : 0.28);
    const capsuleR = 38.0;

    final entry = CurvedAnimation(parent: _entryCtl, curve: Curves.easeOutCubic);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.35),
        end: Offset.zero,
      ).animate(entry),
      child: FadeTransition(
        opacity: entry,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(entry),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              (bottomInset == 0 ? 8 : 4) + bottomInset,
            ),
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(capsuleR),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 44,
                    offset: const Offset(0, 16),
                    spreadRadius: -6,
                  ),
                  BoxShadow(
                    color: glowColor,
                    blurRadius: 26,
                    offset: const Offset(0, 6),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: haloColor.withValues(alpha: dark ? 0.3 : 0.12),
                    blurRadius: 36,
                    offset: Offset.zero,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(capsuleR),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Static frosted-glass layer. Re-captured once per tab switch.
                    RepaintBoundary(
                      key: ValueKey('glass-$_backdropGen'),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                bgColor.withValues(alpha: 0.45),
                                bgColor.withValues(alpha: 0.75),
                                bgColor,
                                bgColor.withValues(alpha: 0.85),
                                bgColor.withValues(alpha: 0.55),
                              ],
                              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(capsuleR),
                            border: Border.all(color: borderColor, width: 0.6),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Specular hairline on the top edge for glass depth.
                              Positioned(
                                top: 0.5,
                                left: 30,
                                right: 30,
                                height: 1,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withValues(
                                          alpha: dark ? 0.5 : 0.7,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Ambient aurora blooms behind the pill.
                              Positioned(
                                left: -28,
                                top: -30,
                                width: 180,
                                height: 130,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        accent.withValues(
                                          alpha: dark ? 0.2 : 0.14,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -30,
                                bottom: -34,
                                width: 170,
                                height: 126,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        cs.tertiary.withValues(
                                          alpha: dark ? 0.18 : 0.12,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (widget.items.length > 1)
                      RepaintBoundary(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final n = widget.items.length;
                            final tabW = constraints.maxWidth / n;
                            // Icon-row geometry inside each tab: icon + gap + label.
                            const iconMetric = 26.0;
                            const labelMetric = 14.0;
                            final iconTop = (constraints.maxHeight -
                                (iconMetric + 2 + labelMetric)) /
                                2;
                            final cy = iconTop + iconMetric / 2;
                            return IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _ctl,
                                builder: (context, _) {
                                  final t = _ctl
                                      .value
                                      .clamp(0, n - 1)
                                      .toDouble();
                                  final center = t.round().clamp(0, n - 1);
                                  final dist = (t - center).abs();
                                  // "Breathing": slim while travelling,
                                  // swell once it lands on a tab.
                                  final breath =
                                      1.0 - (dist * 2.0).clamp(0.0, 1.0);
                                  final easedB =
                                      Curves.easeOut.transform(breath);
                                  final bubbleW =
                                      tabW * (0.5 + 0.31 * easedB);
                                  final h = 40 - 6 * (1 - easedB);
                                  final start =
                                      tabW * (t + 0.5) - bubbleW / 2;
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      PositionedDirectional(
                                        start: start,
                                        top: cy - h / 2,
                                        width: bubbleW,
                                        height: h,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                accent.withValues(
                                                  alpha: dark ? 0.36 : 0.26,
                                                ),
                                                cs.tertiary.withValues(
                                                  alpha: dark ? 0.28 : 0.18,
                                                ),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(h / 2),
                                            border: Border.all(
                                              color: accent.withValues(
                                                alpha: dark ? 0.4 : 0.3,
                                              ),
                                              width: 0.7,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: haloColor,
                                                blurRadius: 20,
                                                spreadRadius: -2,
                                                offset: const Offset(0, 4),
                                              ),
                                              BoxShadow(
                                                color: accent.withValues(
                                                  alpha: dark ? 0.4 : 0.25,
                                                ),
                                                blurRadius: 34,
                                                offset: Offset.zero,
                                              ),
                                            ],
                                          ),
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                h / 2 - 1,
                                              ),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.white.withValues(
                                                    alpha: dark ? 0.24 : 0.4,
                                                  ),
                                                  Colors.transparent,
                                                  Colors.black.withValues(
                                                    alpha: dark ? 0.12 : 0.05,
                                                  ),
                                                ],
                                                stops: const [
                                                  0.0,
                                                  0.45,
                                                  1.0,
                                                ],
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
                    RepaintBoundary(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(widget.items.length, (i) {
                          final item = widget.items[i];
                          final active = widget.selectedIndex == i;
                          return LiquidNavTab(
                            item: item,
                            index: i,
                            active: active,
                            sel: sel,
                            unsel: unsel,
                            accentColor: widget.accentColor,
                            dark: dark,
                            showBadge:
                                widget.badgeIndex == i &&
                                (widget.badgeCount ?? 0) > 0,
                            badgeCount: widget.badgeCount,
                            onTap: () => widget.onTap(i),
                          );
                        }),
                      ),
                    ),
                    RepaintBoundary(
                      child: LiquidNavShine(dark: dark, color: accent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}