import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lazer_widgets/backgrounds/stars_background.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Section1 extends StatefulWidget {
  final ValueChanged<double>? onScrollProgress;

  const Section1({super.key, this.onScrollProgress});

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

    // Notify parent about flash progress
    if (widget.onScrollProgress != null) {
      final scrollOffset = _scrollController.hasClients
          ? _scrollController.offset
          : 0.0;

      // Flash progress from 0.0 to 1.0 during flash duration
      if (scrollOffset < _maxScrollDistance) {
        widget.onScrollProgress!(0.0);
      } else if (scrollOffset < _maxScrollDistance + _flashScrollDistance) {
        final progress =
            ((scrollOffset - _maxScrollDistance) / _flashScrollDistance).clamp(
              0.0,
              1.0,
            );
        widget.onScrollProgress!(progress);
      } else {
        widget.onScrollProgress!(1.0);
      }
    }
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

  double _getEarthTop() {
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    final screenHeight = MediaQuery.of(context).size.height;
    final initialTop = screenHeight * 0.5; // Start at 50% of screen height

    // Move Earth up as scroll increases
    // Max scroll distance determines how much the Earth can move up
    // Earth moves from initial position (50%) to top of screen (0)
    final maxMovement = screenHeight * 0.5; // Can move up by half screen height
    final scrollProgress = (scrollOffset / _maxScrollDistance).clamp(0.0, 1.0);

    // Calculate new top position (decreases as scroll increases)
    final newTop = initialTop - (maxMovement * scrollProgress);

    return newTop.clamp(0.0, screenHeight);
  }

  @override
  Widget build(BuildContext context) {
    final currentScale = _getCurrentScale();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Stack(
        children: [
          // 3D Earth at bottom center (50% of screen height) - below cockpit layer
          // Moves up as user scrolls
          Positioned(
            left: 0,
            right: 0,
            top: _getEarthTop(),
            child: IgnorePointer(
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: ModelViewer(
                    src: 'assets/3d/earth.glb',
                    alt: 'Earth 3D Model',
                    autoRotate: true,
                    cameraControls: false,
                    backgroundColor: Colors.transparent,
                    ar: false,
                    arModes: const [],
                    disableZoom: true,
                  ),
                ),
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

          // Shooting star on top
          // Center(child: CenterShootingStar()),

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
