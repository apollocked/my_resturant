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
  const LiquidGlassNavBar({super.key, required this.items, required this.selectedIndex, required this.onTap, this.badgeCount, this.badgeIndex, this.accentColor = const Color(0xFFE8611A), this.isDark = true});
  @override
  State<LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<LiquidGlassNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctl;
  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..value = widget.selectedIndex.toDouble();
  }
  @override
  void didUpdateWidget(covariant LiquidGlassNavBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) _ctl.animateTo(widget.selectedIndex.toDouble(), duration: const Duration(milliseconds: 400), curve: Curves.easeOutQuint);
  }
  @override
  void dispose() { _ctl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final dark = widget.isDark;
    final sel = dark ? Colors.white : widget.accentColor;
    final unsel = dark ? Colors.white54 : Colors.black45;
    final bgColor = dark ? const Color(0x881A1A2E) : const Color(0x99F8F8F8);
    final borderColor = dark ? const Color(0x22FFFFFF) : const Color(0x18000000);
    final indColor = dark ? const Color(0x1AFFFFFF) : widget.accentColor.withValues(alpha: 0.12);
    final shadowColor = (dark ? Colors.black : Colors.black26).withValues(alpha: dark ? 0.5 : 0.15);
    final glowColor = widget.accentColor.withValues(alpha: dark ? 0.2 : 0.1);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
      child: AnimatedBuilder(
        animation: _ctl,
        builder: (_, _) => Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: shadowColor, blurRadius: 40, offset: const Offset(0, 12), spreadRadius: -4),
              BoxShadow(color: glowColor, blurRadius: 24, offset: const Offset(0, 4), spreadRadius: -2),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: Stack(
                children: [
                  Container(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(widget.items.length, (i) {
                        final item = widget.items[i];
                        final active = widget.selectedIndex == i;
                        return GestureDetector(
                          onTap: () {
                            debugPrint('[NAV] bar-tap index=$i label=${item.label}');
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
                                      duration: const Duration(milliseconds: 350), curve: Curves.easeOutQuint,
                                      width: active ? 48 : 36, height: active ? 32 : 28,
                                      decoration: BoxDecoration(color: active ? indColor : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                                      child: Icon(active ? item.activeIcon : item.icon, size: active ? 24 : 22, color: active ? sel : unsel),
                                    ),
                                    if (widget.badgeIndex == i && (widget.badgeCount ?? 0) > 0)
                                      Positioned(
                                        top: -4, right: -2,
                                        child: Container(
                                          width: 18, height: 18, alignment: Alignment.center,
                                          decoration: BoxDecoration(color: widget.accentColor, shape: BoxShape.circle, border: Border.all(color: dark ? const Color(0xCC1A1A2E) : Colors.white, width: 2)),
                                          child: Text('${widget.badgeCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, height: 1)),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(item.label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? sel : unsel), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Positioned(
                    top: -40, left: -40,
                    child: IgnorePointer(
                      child: Container(
                        width: 200, height: 120,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Colors.white.withValues(alpha: dark ? 0.08 : 0.12), Colors.transparent],
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
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
