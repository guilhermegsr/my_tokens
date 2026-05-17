import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular countdown with the remaining seconds in the center.
class CountdownRing extends StatelessWidget {
  const CountdownRing({
    super.key,
    required this.secondsRemaining,
    required this.period,
    required this.color,
    required this.labelColor,
  });

  final int secondsRemaining;
  final int period;
  final Color color;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: CustomPaint(
        painter: _RingPainter(
          progress: secondsRemaining / period,
          color: color,
        ),
        child: Center(
          child: Text(
            secondsRemaining.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 1.5;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = color;

    // Drains clockwise from the top as the period elapses.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
