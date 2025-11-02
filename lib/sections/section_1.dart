import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lazer_widgets/backgrounds/stars_background.dart';

class Section1 extends StatefulWidget {
  const Section1({super.key});

  @override
  State<Section1> createState() => _Section1State();
}

class _Section1State extends State<Section1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final ScrollController _scrollController;

  // Max scroll distance to reach 50% zoom (1.5x total)
  static const double _maxScrollDistance = 1000.0;
  static const double _flashScrollDistance =
      1000.0; // Additional scroll for flash effect
  static const double _initialScale = 1.1;
  static const double _maxScale = 2; // 1.1 + 50% = 1.65

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    setState(() {
      // Trigger rebuild to update zoom
    });
  }

  double _getCurrentScale() {
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    // Calculate zoom based on scroll position
    // At scroll = 0: scale = 1.1 (initial)
    // At scroll = maxScrollDistance: scale = 1.6 (50% zoom from initial 1.1)
    final progress = (scrollOffset / _maxScrollDistance).clamp(0.0, 1.0);
    return _initialScale + (progress * (_maxScale - _initialScale));
  }

  double _getFlashOpacity() {
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    // Flash starts after maxScrollDistance
    if (scrollOffset < _maxScrollDistance) return 0.0;

    final flashProgress =
        ((scrollOffset - _maxScrollDistance) / _flashScrollDistance).clamp(
          0.0,
          1.0,
        );

    // Start at full opacity, then fade out
    return 1.0 - flashProgress;
  }

  double _getFlashRadius() {
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    // Flash starts after maxScrollDistance
    if (scrollOffset < _maxScrollDistance) return 0.0;

    final flashProgress =
        ((scrollOffset - _maxScrollDistance) / _flashScrollDistance).clamp(
          0.0,
          1.0,
        );

    // Calculate radius based on screen diagonal for full coverage
    final screenSize = MediaQuery.of(context).size;
    final screenDiagonal = math.sqrt(
      screenSize.width * screenSize.width +
          screenSize.height * screenSize.height,
    );

    // Expand from 0 to 2x screen diagonal
    return screenDiagonal * 1.5 * flashProgress;
  }

  @override
  Widget build(BuildContext context) {
    final currentScale = _getCurrentScale();
    final flashOpacity = _getFlashOpacity();
    final flashRadius = _getFlashRadius();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // background image with shake/tremble effect and zoom
          Positioned.fill(
            child: Transform.scale(
              scale: currentScale,
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  // Use sinusoidal functions for smooth shake
                  final time = _shakeController.value * 2 * math.pi;
                  final shakeOffset = Offset(
                    math.sin(time * 1.5) * 5, // smooth horizontal wobble
                    math.cos(time) * 5, // smooth vertical wobble
                  );
                  return Transform.translate(
                    offset: shakeOffset,
                    child: Image.asset('assets/cockpit.png', fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ),
          // Stars background
          const StarsBackground(
            starCount: 200,
            minStarSize: 1.0,
            maxStarSize: 3.0,
            starColor: Colors.white,
            twinkleSpeed: 30.0,
            scrollSpeed: 13.0,
          ),
          // Shooting star on top
          // Center(child: CenterShootingStar()),

          // White flash expanding from center
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: FlashPainter(flashOpacity, flashRadius),
              ),
            ),
          ),

          // ScrollView to enable scrolling
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Container(
              height:
                  MediaQuery.of(context).size.height +
                  _maxScrollDistance +
                  _flashScrollDistance,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

class FlashPainter extends CustomPainter {
  final double opacity;
  final double radius;

  FlashPainter(this.opacity, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || radius <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(FlashPainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.radius != radius;
  }
}
