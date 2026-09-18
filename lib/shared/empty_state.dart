import 'package:flutter/material.dart';

import 'package:my_resturant/core/helpers/responsive.dart';
import 'package:my_resturant/shared/empty_state_icon.dart';

/// A 2026-style empty state: a soft glowing halo behind a floating gradient
/// icon tile that gently bobs, with a spring-like entrance.
///
/// Every list page uses this so a blank zone always reads as "empty on
/// purpose" — the icon carries the context, the halo gives the space depth,
/// and the optional [action] (primary button) points to the next step. The
/// halo and the bobbing tile live in [EmptyStateIcon]; this widget owns the
/// float loop, the entrance mask and the title/subtitle/action column.
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

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
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
    final c = widget.color ?? cs.primary;
    final compact = widget.compact;

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
            EmptyStateIcon(
              icon: widget.icon,
              color: c,
              compact: compact,
              float: _floatCtl,
            ),
            SizedBox(height: compact ? 16 : 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.fontLg(context),
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
                    fontSize: R.fontSm(context),
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