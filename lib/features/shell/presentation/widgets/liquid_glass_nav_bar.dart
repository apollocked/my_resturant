import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:my_resturant/core/theme/app_colors.dart';
import 'package:my_resturant/features/shell/presentation/widgets/liquid_glass_bar_frame.dart';
import 'package:my_resturant/features/shell/presentation/widgets/liquid_glass_chip.dart';
import 'package:my_resturant/features/shell/presentation/widgets/liquid_glass_tab_row.dart';
import 'package:my_resturant/features/shell/presentation/widgets/liquid_nav_item.dart';

/// A 2026 spring-driven floating nav dock: one frosted capsule whose active
/// tab is carried by a damped [SpringSimulation] — narrowing mid-flight, then
/// settling with a magnetic wobble. The dock chrome lives in
/// [LiquidGlassBarFrame]; this widget only drives the chip physics and owns
/// the selected-tab hand-off.
class LiquidGlassNavBar extends StatefulWidget {
  final List<LiquidNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final int? badgeCount;
  final int? badgeIndex;
  final Color accentColor;
  final bool isDark;

  /// Identifies the sliding active indicator in tests.
  static const Key navChipKey = LiquidGlassChip.navChipKey;

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
  static const SpringDescription _spring =
      SpringDescription(mass: 1.0, stiffness: 320, damping: 24);

  /// Bumped on every tab change so the frosted backdrop re-captures the page
  /// behind the dock (kept isolated from the moving chip).
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

  static double _initialTarget(int index, int count) =>
      count <= 0 ? 0 : index.toDouble().clamp(0.0, (count - 1).toDouble()).toDouble();

  @override
  void didUpdateWidget(covariant LiquidGlassNavBar old) {
    super.didUpdateWidget(old);
    final indexChanged = old.selectedIndex != widget.selectedIndex;
    final itemsChanged = !_itemsEqual(old.items, widget.items);
    if (!indexChanged && !itemsChanged) return;
    _backdropGen++;
    if (itemsChanged) {
      // Role bar changed shape mid-life: snap the chip instead of animating
      // across indices that don't exist in the new layout.
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
    final cs = Theme.of(context).colorScheme;
    final dark = widget.isDark;
    final accent = widget.accentColor;
    final unsel = dark
        ? Colors.white.withValues(alpha: 0.5)
        : cs.onSurface.withValues(alpha: 0.45);

    return LiquidGlassBarFrame(
      entry: _entryCtl,
      accentColor: accent,
      dark: dark,
      backdropGen: _backdropGen,
      slots: [
        if (widget.items.length > 1)
          LiquidGlassChip(
            anim: _ctl,
            itemCount: widget.items.length,
            accent: accent,
            dark: dark,
          ),
        LiquidGlassTabRow(
          items: widget.items,
          selectedIndex: widget.selectedIndex,
          onTap: widget.onTap,
          sel: accent,
          unsel: unsel,
          accentColor: widget.accentColor,
          dark: dark,
          badgeIndex: widget.badgeIndex,
          badgeCount: widget.badgeCount,
        ),
      ],
    );
  }
}