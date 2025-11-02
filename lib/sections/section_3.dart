import 'dart:math' as math;
import 'package:flutter/material.dart';

class Section3 extends StatefulWidget {
  const Section3({super.key});

  @override
  State<Section3> createState() => _Section3State();
}

class _Section3State extends State<Section3>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _CurvedGridPainter(animationValue: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _CurvedGridPainter extends CustomPainter {
  final double animationValue;

  _CurvedGridPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Grid parameters
    const int horizontalLines = 15;
    const int verticalLines = 15;
    const double flatEndRatio = 0.6; // 60% of screen height is flat
    const double topWidthRatio = 1.0; // Full width at top
    const double bottomWidthRatio = 2.5; // Expanded at bottom for outer curve
    const double curveControl =
        1.5; // Higher value = smoother transition (no harsh edges)

    // Calculate center for perspective
    final centerX = size.width / 2;
    final flatEndY = size.height * flatEndRatio;

    // Draw horizontal lines (grid lines going left to right)
    for (int i = 0; i < horizontalLines; i++) {
      final t = i / (horizontalLines - 1); // 0 to 1
      final y = size.height * t;

      double currentWidthRatio;
      if (y <= flatEndY) {
        // Flat wall - constant width
        currentWidthRatio = topWidthRatio;
      } else {
        // Curved section - expanding width
        final curvedProgress =
            (y - flatEndY) / (size.height - flatEndY); // 0 to 1
        final curveAmount = math.pow(curvedProgress, curveControl);
        currentWidthRatio =
            topWidthRatio + (bottomWidthRatio - topWidthRatio) * curveAmount;
      }

      // Calculate width at this y position
      final width = size.width * currentWidthRatio;
      final halfWidth = width / 2;

      // Animate horizontal movement
      final offset = math.sin(animationValue * 2 * math.pi + t * math.pi) * 5;

      final path = Path()
        ..moveTo(centerX - halfWidth + offset, y)
        ..lineTo(centerX + halfWidth + offset, y);

      canvas.drawPath(path, paint);
    }

    // Draw vertical lines (grid lines going top to bottom)
    for (int i = 0; i <= verticalLines; i++) {
      final t = i / verticalLines; // Position along width
      final adjustedT = t - 0.5; // Center around 0 (-0.5 to 0.5)

      // Calculate curved path for this vertical line
      final path = Path();
      bool first = true;

      final segments = 100;
      for (int j = 0; j <= segments; j++) {
        final yT = j / segments; // 0 to 1 from top to bottom
        final y = size.height * yT;

        double currentWidthRatio;
        if (y <= flatEndY) {
          // Flat wall - constant width
          currentWidthRatio = topWidthRatio;
        } else {
          // Curved section - expanding width
          final curvedProgress =
              (y - flatEndY) / (size.height - flatEndY); // 0 to 1
          final curveAmount = math.pow(curvedProgress, curveControl);
          currentWidthRatio =
              topWidthRatio + (bottomWidthRatio - topWidthRatio) * curveAmount;
        }

        // Calculate x position based on curve and width expansion
        final width = size.width * currentWidthRatio;
        final halfWidth = width / 2;
        final x = centerX + (adjustedT * halfWidth * 2);

        // Add slight horizontal sway based on position
        final sway = math.sin(animationValue * 2 * math.pi + yT * math.pi) * 3;

        if (first) {
          path.moveTo(x + sway, y);
          first = false;
        } else {
          path.lineTo(x + sway, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_CurvedGridPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
