import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

// Custom smooth scroll physics for ultra-smooth scrolling
class _SmoothScrollPhysics extends ClampingScrollPhysics {
  const _SmoothScrollPhysics({super.parent});

  @override
  _SmoothScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SmoothScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Use spring simulation for smooth deceleration with lower friction
    final tolerance = this.tolerance;
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return ClampingScrollSimulation(
        position: position.pixels,
        velocity: velocity,
        friction: 0.135, // Lower friction = smoother scrolling
        tolerance: tolerance,
      );
    }
    return null;
  }
}

class Section4 extends StatefulWidget {
  const Section4({super.key});

  @override
  State<Section4> createState() => _Section4State();
}

class _Section4State extends State<Section4>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Update immediately for smooth animation
    if (mounted) {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Stack(
        children: [
          // Grid background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _GridPainter(animationValue: _controller.value),
                size: Size.infinite,
              );
            },
          ),
          // Fixed card at bottom of screen that lifts up
          Positioned(
            bottom: -100,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: _LiftingCard(scrollOffset: _scrollOffset),
            ),
          ),
          // Scrollable content (for scroll detection only) - on top to receive touches
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const _SmoothScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              child: SizedBox(
                height: screenHeight * 3, // Space to scroll
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiftingCard extends StatelessWidget {
  final double scrollOffset;

  const _LiftingCard({required this.scrollOffset});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate animation progress based on scroll
    // Card starts lifting immediately as you scroll
    // Animation completes over 2 screen heights for smooth lifting
    final animationRange = screenHeight * 2.0;
    final progress = math.min(1.0, scrollOffset / animationRange);

    // Animation curves for smooth lifting effect (like picking up a laptop)
    final liftProgress = Curves.easeOutCubic.transform(progress);

    // Transform values
    // Start: card lying flat (rotated -90 degrees around x-axis)
    // End: card facing forward (0 rotation, full visibility)

    // Rotation: starts at -90 degrees (flat, facing down), ends at 0 degrees (facing forward)
    final rotationAngle =
        (1.0 - liftProgress) * -math.pi / 2; // -90 to 0 degrees

    // Height adjustment: as card rotates up, lift it slightly
    // When flat, it's at bottom (0 offset). When lifted, move it up for visibility
    final liftHeight = liftProgress * 100.0; // Lift up 100px when fully upright

    // Opacity: fades in as it lifts
    final opacity = 0.0 + (liftProgress * 1.0);

    // Rotate around bottom edge (pivot point at bottom center)
    // Using 3D perspective transform for realistic laptop-opening effect
    return Transform(
      alignment: Alignment.bottomCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Perspective
        ..translate(0.0, -liftHeight) // Move up as it lifts
        ..rotateX(rotationAngle),
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: screenWidth * 0.85,
          height: screenHeight * 0.85,
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.075),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 17, 17, 17),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color.fromARGB(100, 173, 173, 173),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
                offset: Offset(0, 10 * (1 - liftProgress)),
              ),
            ],
          ),
          child: Container(
            width: screenWidth * 0.85,
            height: screenHeight * 0.85,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 26, 26, 26),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double animationValue;

  _GridPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Grid parameters
    const int horizontalLines = 5;
    const int verticalLines = 5;

    // Calculate spacing
    final horizontalSpacing = size.height / horizontalLines;
    final verticalSpacing = size.width / verticalLines;

    // Animated offset for subtle movement
    final offset = animationValue * 2 * math.pi;

    // Calculate all intersection points (actual meeting point of horizontal and vertical lines)
    // Horizontal line at row i: points are at (x + waveOffsetX, baseY)
    // Vertical line at col j: points are at (baseX, y + waveOffsetY)
    // Intersection occurs when: x + waveOffsetX = baseX AND baseY = y + waveOffsetY
    // Solving: x = baseX - waveOffsetX, so intersection point is (baseX, baseY)
    final List<Offset> intersections = [];
    const double edgeMargin =
        100.0; // Don't show dots within this distance from edges

    for (int i = 0; i <= horizontalLines; i++) {
      final baseY = i * horizontalSpacing;

      for (int j = 0; j <= verticalLines; j++) {
        final baseX = j * verticalSpacing;

        // The intersection point is where the lines actually meet:
        // For horizontal line: at x where x + sin(offset + i * 0.1) * 2 = baseX
        // For vertical line: at y where y + cos(offset + j * 0.1) * 2 = baseY
        // The actual drawn point will be (baseX, baseY) because the offsets cancel
        final intersectionX = baseX;
        final intersectionY = baseY;

        // Filter out intersections near screen edges
        if (intersectionX >= edgeMargin &&
            intersectionX <= size.width - edgeMargin &&
            intersectionY >= edgeMargin &&
            intersectionY <= size.height - edgeMargin) {
          intersections.add(Offset(intersectionX, intersectionY));
        }
      }
    }

    // Helper function to calculate opacity based on distance to intersections and screen edges
    double calculateOpacity(
      Offset point,
      Size size,
      List<Offset> intersections,
    ) {
      // Find minimum distance to any intersection
      double minDistToIntersection = double.infinity;
      for (final intersection in intersections) {
        final dist = (point - intersection).distance;
        if (dist < minDistToIntersection) {
          minDistToIntersection = dist;
        }
      }

      // Calculate intersection fade effect (bright near intersections, fade away)
      const double intersectionFadeRadius = 40.0;
      final intersectionFade = math.max(
        0.0,
        1.0 - (minDistToIntersection / intersectionFadeRadius),
      );

      // Calculate edge fade effect
      const double edgeFadeDistance = 100.0;
      final distToLeft = point.dx;
      final distToRight = size.width - point.dx;
      final distToTop = point.dy;
      final distToBottom = size.height - point.dy;

      final edgeFadeLeft = math.min(1.0, distToLeft / edgeFadeDistance);
      final edgeFadeRight = math.min(1.0, distToRight / edgeFadeDistance);
      final edgeFadeTop = math.min(1.0, distToTop / edgeFadeDistance);
      final edgeFadeBottom = math.min(1.0, distToBottom / edgeFadeDistance);

      final edgeFade = math.min(
        math.min(edgeFadeLeft, edgeFadeRight),
        math.min(edgeFadeTop, edgeFadeBottom),
      );

      // Combine intersection brightness and edge fade
      // Make lines more visible - grey color with higher base opacity
      final baseOpacity = 0.2 + (intersectionFade * 0.4);
      return baseOpacity * edgeFade * 0.5; // Reduced by 30%
    }

    // Draw horizontal lines with fading
    for (int i = 0; i <= horizontalLines; i++) {
      final baseY = i * horizontalSpacing;
      final segments = 200; // Number of segments for smooth fading

      for (int seg = 0; seg < segments; seg++) {
        final t1 = seg / segments;
        final t2 = (seg + 1) / segments;

        final x1 = size.width * t1;
        final x2 = size.width * t2;

        final waveOffset1 = math.sin(offset + i * 0.1) * 2;
        final waveOffset2 = math.sin(offset + i * 0.1) * 2;

        final point1 = Offset(x1 + waveOffset1, baseY);
        final point2 = Offset(x2 + waveOffset2, baseY);

        final opacity1 = calculateOpacity(point1, size, intersections);
        final opacity2 = calculateOpacity(point2, size, intersections);

        if (opacity1 > 0.01 || opacity2 > 0.01) {
          final paint = Paint()
            ..color = const Color.fromARGB(
              255,
              150,
              150,
              150,
            ).withOpacity((opacity1 + opacity2) / 2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;

          final path = Path()
            ..moveTo(point1.dx, point1.dy)
            ..lineTo(point2.dx, point2.dy);

          canvas.drawPath(path, paint);
        }
      }
    }

    // Draw vertical lines with fading
    for (int i = 0; i <= verticalLines; i++) {
      final baseX = i * verticalSpacing;
      final segments = 200; // Number of segments for smooth fading

      for (int seg = 0; seg < segments; seg++) {
        final t1 = seg / segments;
        final t2 = (seg + 1) / segments;

        final y1 = size.height * t1;
        final y2 = size.height * t2;

        final waveOffset1 = math.cos(offset + i * 0.1) * 2;
        final waveOffset2 = math.cos(offset + i * 0.1) * 2;

        final point1 = Offset(baseX, y1 + waveOffset1);
        final point2 = Offset(baseX, y2 + waveOffset2);

        final opacity1 = calculateOpacity(point1, size, intersections);
        final opacity2 = calculateOpacity(point2, size, intersections);

        if (opacity1 > 0.01 || opacity2 > 0.01) {
          final paint = Paint()
            ..color = const Color.fromARGB(
              255,
              93,
              93,
              93,
            ).withOpacity((opacity1 + opacity2) / 2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;

          final path = Path()
            ..moveTo(point1.dx, point1.dy)
            ..lineTo(point2.dx, point2.dy);

          canvas.drawPath(path, paint);
        }
      }
    }

    // Draw grey dots at intersections
    final dotPaint = Paint()
      ..color = const Color.fromARGB(171, 40, 40, 40)
      ..style = PaintingStyle.fill;

    for (final intersection in intersections) {
      // Draw dot with slight glow
      final glowDotPaint = Paint()
        ..color = const Color.fromARGB(172, 30, 30, 30).withOpacity(0.4)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(intersection, 4, glowDotPaint);
      canvas.drawCircle(intersection, 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
