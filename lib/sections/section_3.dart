import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lazer_widgets/box/widgets/lazer_path_follower_widget.dart';

class Section3 extends StatefulWidget {
  const Section3({super.key});

  @override
  State<Section3> createState() => _Section3State();
}

class _Section3State extends State<Section3>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _laser1Key = 0;
  int _laser2Key = 0;
  int? _laser1LineIndex;
  int? _laser2LineIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Start firing lasers alternately
    Future.delayed(Duration.zero, () => _fireLaser1());
  }

  void _fireLaser1() {
    if (!mounted) return;
    setState(() {
      _laser1Key++;
      _laser1LineIndex = _getNewLineIndex(avoidingLine: _laser2LineIndex);
    });
    // After 4 seconds (laser duration), fire laser 2
    Future.delayed(const Duration(seconds: 4), _fireLaser2);
  }

  void _fireLaser2() {
    if (!mounted) return;
    setState(() {
      _laser2Key++;
      _laser2LineIndex = _getNewLineIndex(avoidingLine: _laser1LineIndex);
    });
    // After 4 seconds (laser duration), fire laser 1
    Future.delayed(const Duration(seconds: 4), _fireLaser1);
  }

  int _getNewLineIndex({int? avoidingLine}) {
    final random = math.Random();
    final totalLines = 16; // verticalLines + 1 (0 to 15)

    int newLine;
    do {
      newLine = random.nextInt(totalLines);
    } while (newLine == avoidingLine);

    return newLine;
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
      body: Stack(
        children: [
          // Grid background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _CurvedGridPainter(animationValue: _controller.value),
                size: Size.infinite,
              );
            },
          ),
          // Laser 1
          if (_laser1LineIndex != null)
            Positioned.fill(
              key: Key('laser1_$_laser1Key'),
              child: IgnorePointer(
                child: _LaserWidget(
                  lineIndex: _laser1LineIndex!,
                  gridAnimationValue: _controller.value,
                  color: const Color.fromARGB(255, 110, 161, 255),
                  coreColors: const [
                    Color.fromARGB(255, 110, 161, 255),
                    Color.fromARGB(255, 70, 57, 255),
                  ],
                ),
              ),
            ),
          // Laser 2
          if (_laser2LineIndex != null)
            Positioned.fill(
              key: Key('laser2_$_laser2Key'),
              child: IgnorePointer(
                child: _LaserWidget(
                  lineIndex: _laser2LineIndex!,
                  gridAnimationValue: _controller.value,
                  color: const Color.fromARGB(255, 255, 100, 100),
                  coreColors: const [
                    Color.fromARGB(255, 255, 150, 150),
                    Color.fromARGB(255, 255, 50, 50),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LaserWidget extends StatelessWidget {
  final int lineIndex;
  final double gridAnimationValue;
  final Color color;
  final List<Color> coreColors;

  const _LaserWidget({
    required this.lineIndex,
    required this.gridAnimationValue,
    required this.color,
    required this.coreColors,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Grid parameters (same as in _CurvedGridPainter)
        const int verticalLines = 15;
        const double flatEndRatio = 0.6;
        const double topWidthRatio = 1.0;
        const double bottomWidthRatio = 2.5;
        const double curveControl = 1.5;

        final centerX = width / 2;
        final flatEndY = height * flatEndRatio;

        // Use the specified line index
        final t = lineIndex / verticalLines;
        final adjustedT = t - 0.5;

        return LazerPathFollowerWidget(
          pathBuilder: (Size size) {
            // Generate path following the EXACT same vertical line as grid
            final path = Path();
            final segments = 100;
            bool first = true;

            for (int j = 0; j <= segments; j++) {
              final yT = j / segments; // 0 to 1 from top to bottom
              final y = size.height * yT;

              // Calculate width at this height (exact same calculation as grid)
              double currentWidthRatio;
              if (y <= flatEndY) {
                currentWidthRatio = topWidthRatio;
              } else {
                final curvedProgress =
                    (y - flatEndY) / (size.height - flatEndY);
                final curveAmount = math.pow(curvedProgress, curveControl);
                currentWidthRatio =
                    topWidthRatio +
                    (bottomWidthRatio - topWidthRatio) * curveAmount;
              }

              // Calculate x position (exact same calculation as grid)
              final lineWidth = size.width * currentWidthRatio;
              final halfWidth = lineWidth / 2;
              final baseX = centerX + (adjustedT * halfWidth * 2);

              // Add sway (exact same calculation as grid)
              final sway =
                  math.sin(gridAnimationValue * 2 * math.pi + yT * math.pi) * 3;
              final x = baseX + sway;

              if (first) {
                path.moveTo(x, y);
                first = false;
              } else {
                path.lineTo(x, y);
              }
            }

            return path;
          },
          color: color,
          coreColors: coreColors,
          thickness: 3,
          duration: const Duration(seconds: 4),
          showBasePath: false,
        );
      },
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
