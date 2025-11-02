import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A widget that creates an animated starfield background
class StarsBackground extends StatefulWidget {
  const StarsBackground({
    super.key,
    this.starCount = 200,
    this.minStarSize = 1.0,
    this.maxStarSize = 3.0,
    this.starColor = Colors.white,
    this.twinkleSpeed = 2.0,
  });

  final int starCount;
  final double minStarSize;
  final double maxStarSize;
  final Color starColor;
  final double twinkleSpeed;

  @override
  State<StarsBackground> createState() => _StarsBackgroundState();
}

class _StarsBackgroundState extends State<StarsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Star> _stars;
  late final math.Random _random;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _random = math.Random();
    _stars = List.generate(
      widget.starCount,
      (index) {
        // Randomize twinkle speed for variety - some stars twinkle fast, some slow, some not at all
        final speedVariation = _random.nextDouble();
        late double speed;
        if (speedVariation < 0.3) {
          // 30% of stars don't twinkle (speed = 0)
          speed = 0;
        } else if (speedVariation < 0.6) {
          // 30% of stars twinkle slowly
          speed = widget.twinkleSpeed * 0.5;
        } else if (speedVariation < 0.85) {
          // 25% of stars twinkle at normal speed
          speed = widget.twinkleSpeed;
        } else {
          // 15% of stars twinkle fast
          speed = widget.twinkleSpeed * 2.0;
        }
        
        return Star(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: widget.minStarSize +
              _random.nextDouble() * (widget.maxStarSize - widget.minStarSize),
          twinkleDelay: _random.nextDouble() * math.pi * 2,
          twinkleSpeed: speed,
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant StarsBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.starCount != widget.starCount ||
        oldWidget.minStarSize != widget.minStarSize ||
        oldWidget.maxStarSize != widget.maxStarSize ||
        oldWidget.twinkleSpeed != widget.twinkleSpeed) {
      _stars.clear();
      _stars.addAll(
        List.generate(
          widget.starCount,
          (index) {
            // Randomize twinkle speed for variety - some stars twinkle fast, some slow, some not at all
            final speedVariation = _random.nextDouble();
            late double speed;
            if (speedVariation < 0.3) {
              // 30% of stars don't twinkle (speed = 0)
              speed = 0;
            } else if (speedVariation < 0.6) {
              // 30% of stars twinkle slowly
              speed = widget.twinkleSpeed * 0.5;
            } else if (speedVariation < 0.85) {
              // 25% of stars twinkle at normal speed
              speed = widget.twinkleSpeed;
            } else {
              // 15% of stars twinkle fast
              speed = widget.twinkleSpeed * 2.0;
            }
            
            return Star(
              x: _random.nextDouble(),
              y: _random.nextDouble(),
              size: widget.minStarSize +
                  _random.nextDouble() *
                      (widget.maxStarSize - widget.minStarSize),
              twinkleDelay: _random.nextDouble() * math.pi * 2,
              twinkleSpeed: speed,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StarsPainter(
            stars: _stars,
            starColor: widget.starColor,
            time: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Star {
  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleDelay,
    required this.twinkleSpeed,
  });

  final double x;
  final double y;
  final double size;
  final double twinkleDelay;
  final double twinkleSpeed;
}

class StarsPainter extends CustomPainter {
  StarsPainter({
    required this.stars,
    required this.starColor,
    required this.time,
  });

  final List<Star> stars;
  final Color starColor;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      // Calculate twinkle effect using a sinusoidal function
      final twinkleValue = star.twinkleSpeed == 0
          ? 1.0 // Static stars have constant brightness
          : 0.5 +
              0.5 *
                  math.sin(
                    time * star.twinkleSpeed * math.pi * 2 + star.twinkleDelay,
                  );
      // More dramatic opacity range for better twinkling
      final opacity = 0.1 + (twinkleValue * 0.9); // Opacity between 0.1 and 1.0

      final xPos = star.x * size.width;
      final yPos = star.y * size.height;

      // Draw glow layers for twinkling stars using multiple overlapping circles
      if (star.twinkleSpeed > 0 && opacity > 0.3) {
        // Only draw glow when star is relatively bright
        // Outer glow (large, subtle)
        final outerGlowPaint = Paint()
          ..color = starColor.withOpacity(opacity * 0.15);
        canvas.drawCircle(
          Offset(xPos, yPos),
          star.size * 1.8,
          outerGlowPaint,
        );

        // Mid glow
        final midGlowPaint = Paint()
          ..color = starColor.withOpacity(opacity * 0.3);
        canvas.drawCircle(
          Offset(xPos, yPos),
          star.size * 1.2,
          midGlowPaint,
        );
      }

      // Core star
      final corePaint = Paint()
        ..color = starColor.withOpacity(opacity);
      canvas.drawCircle(
        Offset(xPos, yPos),
        star.size / 2,
        corePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarsPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.stars != stars ||
        oldDelegate.starColor != starColor;
  }
}

