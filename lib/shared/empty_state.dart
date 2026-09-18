import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

/// A 2026-style empty state: a soft glowing halo behind a floating gradient
/// icon tile that gently bobs, with a spring-like entrance.
///
/// Every list page uses this so a blank zone always reads as "empty on
/// purpose" — the icon carries the context, the halo gives the space depth,
/// and the optional [action] (primary button) points to the next step.
class EmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final Widget? action;

  /// Smaller sizing for tight spots (bottom sheets, search areas).
  final bool compact;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    this.action,
    this.compact = false,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtl;

  @override
  void initState() {
    super.initState();
    _floatCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = widget.color ?? Theme.of(context).colorScheme.primary;
    final compact = widget.compact;
    final tile = compact ? 84.0 : R.avatarSize(context);
    final glow = tile * (compact ? 2.2 : 2.6);
    final iconSize = tile * (compact ? 0.42 : 0.45);
    final titleSize = R.fontLg(context);
    final subSize = compact ? R.fontSm(context) : R.fontSm(context);

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 16),
              child: Transform.scale(
                scale: 0.94 + 0.06 * Curves.easeOutBack.transform(t),
                child: child,
              ),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: glow,
              height: glow,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Halo / ambient glow behind the icon tile.
                  Container(
                    width: glow,
                    height: glow,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          c.withValues(alpha: compact ? 0.16 : 0.14),
                          c.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.55, 1],
                      ),
                    ),
                  ),
                  // Two blurred depth orbs.
                  Positioned(
                    top: glow * 0.12,
                    left: glow * 0.18,
                    child: _Orb(size: compact ? 10 : 14, color: c),
                  ),
                  Positioned(
                    bottom: glow * 0.12,
                    right: glow * 0.14,
                    child: _Orb(size: compact ? 7 : 10, color: c),
                  ),
                  // Floating icon tile.
                  AnimatedBuilder(
                    animation: _floatCtl,
                    builder: (context, _) {
                      final dy =
                          math.sin(_floatCtl.value * 2 * math.pi) * (compact ? 3 : 4);
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: Container(
                          width: tile,
                          height: tile,
                          alignment: Alignment.center,
                          // Rounded-rect squircle (consistent with the dock).
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(tile * 0.32),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                c.withValues(alpha: 0.32),
                                c.withValues(alpha: 0.12),
                              ],
                            ),
                            border: Border.all(
                              color: c.withValues(alpha: 0.30),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: c.withValues(alpha: 0.18),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(widget.icon, size: iconSize, color: c),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: compact ? 16 : 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  widget.subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: subSize,
                    height: 1.45,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            if (widget.action != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: widget.action!,
              ),
          ],
        ),
      ),
    );
  }
}

/// A soft blurred dot used to give the empty state extra depth.
class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.22),
      ),
    );
  }
}