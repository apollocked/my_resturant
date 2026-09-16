import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/features/shell/presentation/widgets/liquid_nav_item.dart';
import 'package:my_resturant/features/shell/presentation/widgets/liquid_nav_tab.dart';

/// A 2026 spring-driven floating nav dock.
///
/// One softly frosted capsule that floats above the content. The active tab
/// is marked by a squircled tonal indicator that is carried between tabs by a
/// damped [SpringSimulation] — it narrows mid-flight, then swells and wobbles
/// back into place with a magnetic settle. No glow-noise: state is carried by
/// the chip fill, the icon pop and the label weight.
class LiquidGlassNavBar extends StatefulWidget {
  final List<LiquidNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final int? badgeCount;
  final int? badgeIndex;
  final Color accentColor;
  final bool isDark;

  /// Identifies the sliding active indicator in tests.
  static const Key navChipKey = ValueKey('liquid-nav-chip');

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

  /// Magnetic snap physics used for every tab change.
  static const SpringDescription _spring = SpringDescription(
    mass: 1.0,
    stiffness: 320,
    damping: 24,
  );

  /// Bumped on every tab change so the frosted backdrop re-captures the page
  /// behind the dock (kept isolated from the moving chip, whose animation
  /// state stays untouched).
  int _backdropGen = 0;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
      upperBound: 16,
    )..value = _initialTarget(widget.selectedIndex, widget.items.length);
    _entryCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    )..animateWith(SpringSimulation(_spring, 0, 1, 0));
  }

  static double _initialTarget(int index, int count) {
    if (count <= 0) return 0;
    return index.toDouble().clamp(0.0, (count - 1).toDouble()).toDouble();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassNavBar old) {
    super.didUpdateWidget(old);
    final indexChanged = old.selectedIndex != widget.selectedIndex;
    final itemsChanged = !_itemsEqual(old.items, widget.items);
    if (!indexChanged && !itemsChanged) return;
    _backdropGen++;
    if (itemsChanged) {
      // Role bar changed shape mid-life: snap the chip to the new position
      // instead of animating across indices that don't exist in the new
      // layout (e.g. admin's 5 tabs shrinking to kitchen's 2).
      _ctl.value = _initialTarget(widget.selectedIndex, widget.items.length);
    } else if (indexChanged) {
      // Magnetic snap: physics-driven settle with a soft wobble on arrival.
      _ctl.animateWith(
        SpringSimulation(
          _spring,
          _ctl.value,
          widget.selectedIndex.toDouble(),
          0,
        ),
      );
    }
  }

  static bool _itemsEqual(List<LiquidNavItem> a, List<LiquidNavItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].icon != b[i].icon ||
          a[i].activeIcon != b[i].activeIcon ||
          a[i].label != b[i].label) {
        return false;
      }
    }
    return true;
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
    final unsel = dark
        ? Colors.white.withValues(alpha: 0.5)
        : cs.onSurface.withValues(alpha: 0.45);
    // Dark mode is a flat theme surface; light mode keeps a soft gradient.
    final bgTop = dark ? cs.surface : const Color(0xF2FDFBF8);
    final bgBottom = dark ? cs.surface : const Color(0xE6F2EDE6);
    // A whisper of the accent keeps light mode reading as living glass.
    final tintAmt = dark ? 0.0 : 0.035;
    final glassTop = Color.lerp(bgTop, accent, tintAmt)!;
    final glassBottom = Color.lerp(bgBottom, accent, tintAmt)!;
    final borderColor = dark
        ? const Color(0xFF2E2E2E)
        : Colors.black.withValues(alpha: 0.06);
    final shadow = cs.shadow.withValues(alpha: dark ? 0.45 : 0.14);
    const capsuleR =
        17.0; // squared dock, same corner radius as the active pill
    const barH = 72.0;

    // Spring-driven entrance (slide + fade) with a soft settle.
    final entry = _entryCtl;
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end: Offset.zero,
    ).animate(entry);

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: entry,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset),
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
                  // Frosted glass layer, re-captured once per tab switch.
                  RepaintBoundary(
                    key: ValueKey('glass-$_backdropGen'),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [glassTop, glassBottom],
                          ),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  if (widget.items.length > 1)
                    RepaintBoundary(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final n = widget.items.length;
                          final tabW = constraints.maxWidth / n;
                          // The active indicator wraps the icon AND the label
                          // but keeps a breath of cell on each side. It
                          // narrows in flight, then swolels out on land.
                          const landedH = 48.0;
                          const pillR = 17.0;
                          const pillCY = 36.0; // bar mid-height (72 / 2)
                          const landedFrac = 0.86; // seated width of the cell
                          const flightFrac = 0.60; // mid-flight width factor
                          return IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _ctl,
                              builder: (context, _) {
                                final t = _ctl.value.clamp(0, n - 1).toDouble();
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
                                          borderRadius: BorderRadius.circular(
                                            glowH / 2,
                                          ),
                                          gradient: RadialGradient(
                                            colors: [
                                              accent.withValues(
                                                alpha:
                                                    (dark ? 0.11 : 0.06) *
                                                    landedness,
                                              ),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Active cell wrapper: covers icon + label.
                                    PositionedDirectional(
                                      key: LiquidGlassNavBar.navChipKey,
                                      start: start,
                                      top: top,
                                      width: w,
                                      height: h,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            pillR,
                                          ),
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
                                            borderRadius: BorderRadius.circular(
                                              pillR - 1,
                                            ),
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
                          sel: accent,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
