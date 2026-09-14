import 'dart:math' as math;

import 'package:flutter/material.dart';

class OrbitRingPainter extends CustomPainter {
  const OrbitRingPainter({required this.accent, required this.track});

  final Color accent;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 6.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    final arcRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * 0.82,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 2,
          colors: [
            accent.withValues(alpha: 0.0),
            accent.withValues(alpha: 0.35),
            accent,
          ],
        ).createShader(arcRect),
    );

    final tipAngle = -math.pi / 2 + math.pi * 2 * 0.82;
    final tip =
        center + Offset(math.cos(tipAngle), math.sin(tipAngle)) * radius;
    canvas.drawCircle(tip, stroke * 0.9, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(OrbitRingPainter old) =>
      old.accent != accent || old.track != track;
}

class BurstPainter extends CustomPainter {
  const BurstPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    for (var i = 0; i < 3; i++) {
      final t = ((progress * 1.15) - i * 0.28).clamp(0.0, 1.0);
      final radius = 4 + maxRadius * t;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = color.withValues(alpha: (1 - t) * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(BurstPainter old) =>
      old.progress != progress || old.color != color;
}
