import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LiquidNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const LiquidNavItem({required this.icon, required this.activeIcon, required this.label});
}

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
    this.accentColor = const Color(0xFFE8611A),
    this.isDark = true,
  });

  @override
  State<LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<LiquidGlassNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _indicatorCtl;

  @override
  void initState() {
    super.initState();
    _indicatorCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _indicatorCtl.value = widget.selectedIndex.toDouble();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassNavBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      _indicatorCtl.animateTo(
        widget.selectedIndex.toDouble(),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuint,
      );
    }
  }

  @override
  void dispose() {
    _indicatorCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.items.length;
    final selColor = widget.isDark ? Colors.white : widget.accentColor;
    final unselColor = widget.isDark ? Colors.white54 : Colors.black45;
    final glassColor = widget.isDark
        ? const Color(0x0DFFFFFF)
        : const Color(0x0D000000);
    final borderColor = widget.isDark
        ? const Color(0x1AFFFFFF)
        : const Color(0x1A000000);
    final indicatorColor = widget.isDark
        ? const Color(0x1AFFFFFF)
        : widget.accentColor.withValues(alpha: 0.12);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: AnimatedBuilder(
        animation: _indicatorAnim,
        builder: (_, _) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: glassColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isDark ? Colors.black : Colors.black26).withValues(alpha: widget.isDark ? 0.25 : 0.08),
                      blurRadius: 40,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(itemCount, (i) {
                    final item = widget.items[i];
                    final isSelected = widget.selectedIndex == i;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onTap(i);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 64,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutQuint,
                                  width: isSelected ? 48 : 36,
                                  height: isSelected ? 32 : 28,
                                  decoration: BoxDecoration(
                                    color: isSelected ? indicatorColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isSelected ? item.activeIcon : item.icon,
                                    size: isSelected ? 24 : 22,
                                    color: isSelected ? selColor : unselColor,
                                  ),
                                ),
                                if (widget.badgeIndex == i && (widget.badgeCount ?? 0) > 0)
                                  Positioned(
                                    top: -4,
                                    right: -2,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: widget.accentColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: widget.isDark
                                              ? const Color(0xFF1A1A2E)
                                              : Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Text(
                                        '${widget.badgeCount}',
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
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? selColor : unselColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => builder(context, null);
}
