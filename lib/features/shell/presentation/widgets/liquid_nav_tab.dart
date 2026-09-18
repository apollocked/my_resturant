import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/features/shell/presentation/widgets/animated_nav_icon.dart';
import 'package:my_resturant/features/shell/presentation/widgets/liquid_nav_badge.dart';
import 'package:my_resturant/features/shell/presentation/widgets/liquid_nav_item.dart';

class LiquidNavTab extends StatefulWidget {
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
  State<LiquidNavTab> createState() => _LiquidNavTabState();
}

class _LiquidNavTabState extends State<LiquidNavTab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _pressed = true);
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedNavIcon(
                    active: widget.active,
                    icon: item.icon,
                    activeIcon: item.activeIcon,
                    color: widget.sel,
                    inactiveColor: widget.unsel,
                    size: 22,
                  ),
                  if (widget.showBadge)
                    PositionedDirectional(
                      top: -5,
                      end: -8,
                      child: LiquidNavBadge(
                        count: widget.badgeCount ?? 0,
                        accentColor: widget.accentColor,
                        borderColor: widget.dark
                            ? const Color(0xE0161820)
                            : Theme.of(context).colorScheme.surface,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize:
                      R.fontSm(context) + (widget.active ? 1 : 0),
                  fontWeight:
                      widget.active ? FontWeight.w700 : FontWeight.w500,
                  height: 1.1,
                  color: widget.active ? widget.sel : widget.unsel,
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
      ),
    );
  }
}