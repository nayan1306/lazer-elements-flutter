import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lazer_widgets/triangle/widgets/triangle_lazer_follower.dart';

class TriangleLazer extends StatefulWidget {
  const TriangleLazer({super.key});

  @override
  State<TriangleLazer> createState() => _TriangleLazerState();
}

class _TriangleLazerState extends State<TriangleLazer> {
  bool _reverseFirstLazer = false; // Both go from top to bottom
  bool _reverseSecondLazer = false;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;

    // Use 80% of the smaller dimension, with a max of 600 and min of 200
    final double baseSize =
        (screenWidth < screenHeight ? screenWidth : screenHeight) * 0.8;
    final double triangleSize = baseSize.clamp(200.0, 600.0);

    const double thickness = 3;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Direction controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Lazer 1: ',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Switch(
                    value: _reverseFirstLazer,
                    onChanged: (value) {
                      setState(() {
                        _reverseFirstLazer = value;
                      });
                    },
                    activeColor: const Color.fromARGB(255, 208, 40, 40),
                  ),
                  const Text(
                    'Reverse',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Lazer 2: ',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Switch(
                    value: _reverseSecondLazer,
                    onChanged: (value) {
                      setState(() {
                        _reverseSecondLazer = value;
                      });
                    },
                    activeColor: const Color.fromARGB(255, 208, 40, 40),
                  ),
                  const Text(
                    'Reverse',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Triangle lazer widget
        SizedBox(
          width: triangleSize,
          height: triangleSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Base triangle border
              CustomPaint(
                size: Size(triangleSize, triangleSize),
                painter: _TriangleBorderPainter(),
              ),
              // Dual lazer overlay following the triangle path
              Positioned.fill(
                child: IgnorePointer(
                  child: TriangleLazerFollower(
                    showBasePath: false,
                    color: const Color.fromARGB(255, 208, 40, 40),
                    coreColors: [
                      const Color.fromARGB(255, 255, 183, 77),
                      const Color.fromARGB(255, 255, 112, 67),
                    ],
                    thickness: thickness,
                    duration: const Duration(seconds: 4),
                    bidirectionalTrail: true,
                    trailLength: 150,
                    reverseFirstLazer: _reverseFirstLazer,
                    reverseSecondLazer: _reverseSecondLazer,
                    pathBuilder: (size) {
                      final double side = size.width * 0.9;
                      final double centerX = size.width / 2;
                      final double centerY = size.height / 2;

                      // Calculate vertices of an equilateral triangle
                      // Starting from top vertex, going clockwise
                      final double height = side * math.sqrt(3) / 2;

                      final Point top = Point(
                        centerX,
                        centerY - height * (2 / 3),
                      );
                      final Point bottomLeft = Point(
                        centerX - side / 2,
                        centerY + height / 3,
                      );
                      final Point bottomRight = Point(
                        centerX + side / 2,
                        centerY + height / 3,
                      );

                      final Path triangle = Path()
                        ..moveTo(top.x, top.y)
                        ..lineTo(bottomRight.x, bottomRight.y)
                        ..lineTo(bottomLeft.x, bottomLeft.y)
                        ..close();

                      return triangle;
                    },
                    firstPathBuilder: (size) {
                      // First lazer: top -> right bottom -> center of base
                      final double side = size.width * 0.9;
                      final double centerX = size.width / 2;
                      final double centerY = size.height / 2;
                      final double height = side * math.sqrt(3) / 2;

                      final Point top = Point(
                        centerX,
                        centerY - height * (2 / 3),
                      );
                      final Point bottomRight = Point(
                        centerX + side / 2,
                        centerY + height / 3,
                      );
                      final Point bottomCenter = Point(
                        centerX,
                        centerY + height / 3,
                      );

                      return Path()
                        ..moveTo(top.x, top.y)
                        ..lineTo(bottomRight.x, bottomRight.y)
                        ..lineTo(bottomCenter.x, bottomCenter.y);
                    },
                    secondPathBuilder: (size) {
                      // Second lazer: top -> left bottom -> center of base
                      final double side = size.width * 0.9;
                      final double centerX = size.width / 2;
                      final double centerY = size.height / 2;
                      final double height = side * math.sqrt(3) / 2;

                      final Point top = Point(
                        centerX,
                        centerY - height * (2 / 3),
                      );
                      final Point bottomLeft = Point(
                        centerX - side / 2,
                        centerY + height / 3,
                      );
                      final Point bottomCenter = Point(
                        centerX,
                        centerY + height / 3,
                      );

                      return Path()
                        ..moveTo(top.x, top.y)
                        ..lineTo(bottomLeft.x, bottomLeft.y)
                        ..lineTo(bottomCenter.x, bottomCenter.y);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Simple Point class for triangle calculations
class Point {
  final double x;
  final double y;
  Point(this.x, this.y);
}

/// Painter for the base triangle border
class _TriangleBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double side = size.width * 0.9;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final double height = side * math.sqrt(3) / 2;

    final Point top = Point(centerX, centerY - height * (2 / 3));
    final Point bottomLeft = Point(centerX - side / 2, centerY + height / 3);
    final Point bottomRight = Point(centerX + side / 2, centerY + height / 3);

    final Path triangle = Path()
      ..moveTo(top.x, top.y)
      ..lineTo(bottomRight.x, bottomRight.y)
      ..lineTo(bottomLeft.x, bottomLeft.y)
      ..close();

    final Paint paint = Paint()
      ..color = const Color.fromARGB(83, 35, 35, 35)
      ..style = PaintingStyle.fill;

    canvas.drawPath(triangle, paint);

    final Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(triangle, borderPaint);
  }

  @override
  bool shouldRepaint(_TriangleBorderPainter oldDelegate) => false;
}
