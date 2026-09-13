import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/shared/animated_nav_icon.dart';
import 'package:my_resturant/shared/liquid_nav_item.dart';

class LiquidNavTab extends StatelessWidget {
  const LiquidNavTab({
    super.key,
    required this.item,
    required this.index,
    required this.active,
    required this.sel,
    required this.unsel,
    required this.accentColor,
    required this.dark,
    required this.showBadge,
    required this.badgeCount,
    required this.onTap,
  });

  final LiquidNavItem item;
  final int index;
  final bool active;
  final Color sel;
  final Color unsel;
  final Color accentColor;
  final bool dark;
  final bool showBadge;
  final int? badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedNavIcon(
                  active: active,
                  icon: item.icon,
                  activeIcon: item.activeIcon,
                  color: sel,
                  inactiveColor: unsel,
                  size: 24,
                ),
                if (showBadge)
                  PositionedDirectional(
                    top: -6,
                    end: -7,
                    child: _AuroraBadge(
                      count: badgeCount ?? 0,
                      accentColor: accentColor,
                      borderColor: dark ? const Color(0xE0252535) : cs.surface,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: R.fontSm(context) + (active ? 1 : 0),
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                height: 1.15,
                color: active ? sel : unsel,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tiny glass capsule that carries the cart/order count.
class _AuroraBadge extends StatelessWidget {
  const _AuroraBadge({
    required this.count,
    required this.accentColor,
    required this.borderColor,
  });

  final int count;
  final Color accentColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
      child: Container(
        key: ValueKey(count),
        alignment: Alignment.center,
        constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(accentColor, Colors.white, 0.25)!,
              accentColor,
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.6),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.45),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '$count',
          style: TextStyle(
            color: cs.onPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}