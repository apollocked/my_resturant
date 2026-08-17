import 'dart:ui';

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
        color: dark ? const Color(0xB3121A2A) : const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: dark ? 0.10 : 0.5),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.5 : 0.14),
            blurRadius: 60,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: child,
      ),
    );
  }
}
