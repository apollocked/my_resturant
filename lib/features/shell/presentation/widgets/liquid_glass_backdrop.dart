import 'dart:ui';

import 'package:flutter/material.dart';

/// The frosted-glass layer behind the nav dock.
///
/// A live [BackdropFilter] that re-captures the page behind the dock once per
/// tab change ([backdropGen]) so the blur stays isolated from the moving chip
/// animation.
class LiquidGlassBackdrop extends StatelessWidget {
  final Color top;
  final Color bottom;
  final Color borderColor;
  final int backdropGen;

  const LiquidGlassBackdrop({
    super.key,
    required this.top,
    required this.bottom,
    required this.borderColor,
    required this.backdropGen,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: ValueKey('glass-$backdropGen'),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [top, bottom],
            ),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: const SizedBox.shrink(),
        ),
      ),
    );
  }
}