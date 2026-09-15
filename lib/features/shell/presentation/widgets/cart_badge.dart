import 'package:flutter/material.dart';
import 'package:my_resturant/core/theme/app_colors.dart';

/// Bouncy animated pill that shows a numeric count. Scales up with an overshoot
/// curve when [count] changes, providing satisfying visual feedback.
///
/// ```dart
/// CartBadge(count: state.cartCount)
/// ```
class CartBadge extends StatefulWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;

  const CartBadge({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<CartBadge> createState() => _CartBadgeState();
}

class _CartBadgeState extends State<CartBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0,
      upperBound: 1,
    );
    _scaleAnim = Tween<double>(begin: 1, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant CartBadge old) {
    super.didUpdateWidget(old);
    if (old.count != widget.count && widget.count > 0) {
      _ctrl
        ..reset()
        ..forward();
      _scaleAnim = Tween<double>(begin: 1.3, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count == 0) return const SizedBox.shrink();
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${widget.count}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: widget.textColor ?? Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
