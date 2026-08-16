import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/shared/liquid_nav_item.dart';

class LiquidNavTab extends StatelessWidget {
  const LiquidNavTab({
    super.key,
    required this.item,
    required this.index,
    required this.active,
    required this.sel,
    required this.unsel,
    required this.indColor,
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
  final Color indColor;
  final Color accentColor;
  final bool dark;
  final bool showBadge;
  final int? badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutQuint,
                  width: active ? 48 : 36,
                  height: active ? 32 : 28,
                  decoration: BoxDecoration(
                    color: active ? indColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    active ? item.activeIcon : item.icon,
                    size: active ? 24 : 22,
                    color: active ? sel : unsel,
                  ),
                ),
                if (showBadge)
                  Positioned(
                    top: -4,
                    right: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: dark ? const Color(0xCC1A1A2E) : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${badgeCount ?? 0}',
                        style: const TextStyle(
                          color: Colors.white,
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
            Text(
              item.label,
              style: TextStyle(
                fontSize: R.fontSm(context),
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? sel : unsel,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
