import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/shared/liquid_nav_item.dart';
import 'package:my_resturant/shared/liquid_nav_shine.dart';
import 'package:my_resturant/shared/liquid_nav_tab.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _ctl;

  /// Bumped on every tab change so the glass backdrop re-captures the page
  /// behind the bar (kept isolated from the moving bubble, which keeps its
  /// own animation state untouched).
  int _backdropGen = 0;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..value = widget.selectedIndex.toDouble();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final cs = Theme.of(context).colorScheme;
    final dark = widget.isDark;
    final sel = widget.accentColor;
    final unsel = dark
        ? Colors.white.withValues(alpha: 0.6)
        : cs.onSurface.withValues(alpha: 0.45);
    final bgColor = dark ? const Color(0xE0252535) : const Color(0x99F8F8F8);
    final borderColor = dark
        ? widget.accentColor.withValues(alpha: 0.45)
        : const Color(0x18000000);
    final shadowColor = cs.shadow.withValues(alpha: dark ? 0.5 : 0.15);
    final glowColor = widget.accentColor.withValues(alpha: dark ? 0.2 : 0.1);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        (bottomInset == 0 ? 6 : 2) + bottomInset,
      ),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 40,
              offset: const Offset(0, 12),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: glowColor,
              blurRadius: 24,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
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
                          bgColor.withValues(alpha: 0.8),
                          bgColor.withValues(alpha: 0.5),
                        ],
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: borderColor, width: 0.5),
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
                      final bubbleW = tabW * 0.8;
                      // Icon-row geometry inside each tab: icon + gap + label.
                      const iconMetric = 26.0;
                      const labelMetric = 14.0;
                      final iconTop = (constraints.maxHeight -
                          (iconMetric + 2 + labelMetric)) /
                          2;
                      const bubbleH = 38.0;
                      final top = iconTop + iconMetric / 2 - bubbleH / 2;
                      return IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _ctl,
                          builder: (context, _) {
                            final t = _ctl
                                .value
                                .clamp(0, n - 1)
                                .toDouble();
                            final left = tabW * (t + 0.5) - bubbleW / 2;
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Positioned(
                                  left: left,
                                  top: top,
                                  width: bubbleW,
                                  height: bubbleH,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          widget.accentColor.withValues(
                                            alpha: dark ? 0.28 : 0.20,
                                          ),
                                          widget.accentColor.withValues(
                                            alpha: dark ? 0.18 : 0.12,
                                          ),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: widget.accentColor.withValues(
                                          alpha: dark ? 0.24 : 0.16,
                                        ),
                                        width: 0.8,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: glowColor,
                                          blurRadius: 18,
                                          spreadRadius: -2,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
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
              RepaintBoundary(child: LiquidNavShine(dark: dark)),
            ],
          ),
        ),
      ),
    );
  }
}
