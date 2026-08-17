import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class RoleOverlayCard extends StatelessWidget {
  const RoleOverlayCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: EdgeInsets.symmetric(
        horizontal: R.isPhone(context) ? 24 : 36,
        vertical: R.isPhone(context) ? 28 : 32,
      ),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF121A2A) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE0E0E0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.5 : 0.14),
            blurRadius: 60,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: child,
    );
  }
}
