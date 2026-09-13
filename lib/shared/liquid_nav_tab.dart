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
          debugPrint('[NAV] bar-tap index=$index label=${item.label}');
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
                    top: -4,
                    end: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: dark ? const Color(0xE0252535) : cs.surface,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${badgeCount ?? 0}',
                        style: TextStyle(
                          color: dark ? Colors.white : cs.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: R.fontSm(context),
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
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