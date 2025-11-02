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

  // Smooth easing function for ultra-smooth transitions
  double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - (math.pow(-2 * t + 2, 3) / 2);
  }

  double _easeOutCubic(double t) {
    return 1 - math.pow(1 - t, 3).toDouble();
  }

  double _getCurrentScale() {
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    // Phase 1: First 1000px - normal zoom from 1.1 to 2.0 with smooth easing
    if (scrollOffset <= _maxScrollDistance) {
      final rawProgress = (scrollOffset / _maxScrollDistance).clamp(0.0, 1.0);
      final smoothProgress = _easeInOutCubic(rawProgress);
      return _initialScale + (smoothProgress * (_maxScale - _initialScale));
    }

    // Phase 2: Next 1000px - additional zoom at 2X rate from bottom 50%
    // Zoom from 2.0 up to 2.0 + (2.0 * 0.5) = 3.0 with smooth easing
    final phase2Offset = scrollOffset - _maxScrollDistance;
    final rawPhase2Progress = (phase2Offset / _flashScrollDistance).clamp(
      0.0,
      1.0,
    );
    final smoothPhase2Progress = _easeInOutCubic(rawPhase2Progress);
    final phase2Scale =
        _maxScale +
        (smoothPhase2Progress * (_maxScale * 0.5)); // 2X rate = 50% more

    // Phase 3: After 2000px - gradually diminish by 5% with smooth easing
    if (scrollOffset > _maxScrollDistance + _flashScrollDistance) {
      final phase3Offset =
          scrollOffset - (_maxScrollDistance + _flashScrollDistance);
      final maxPhase3Scale = _maxScale * 1.5; // Max scale from phase 2
      final diminishAmount = maxPhase3Scale * 0.05; // 5% reduction

      // Diminish gradually over 500px with smooth easing
      final rawDiminishProgress = math.min(phase3Offset / 500.0, 1.0);
      final smoothDiminishProgress = _easeOutCubic(rawDiminishProgress);
      return maxPhase3Scale - (diminishAmount * smoothDiminishProgress);
    }

    return phase2Scale;
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

  double _getCockpitOpacity() {
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    // Start fading at 1700px
    const double fadeStartOffset = 1700.0;
    // Complete fade by 2000px (300px fade distance)
    const double fadeEndOffset = 2000.0;
    const double fadeDistance = fadeEndOffset - fadeStartOffset; // 300px

    // Fully visible before fade starts
    if (scrollOffset < fadeStartOffset) {
      return 1.0;
    }

    // Completely transparent after fade completes
    if (scrollOffset >= fadeEndOffset) {
      return 0.0;
    }

    // Fade from 1.0 to 0.0 over 300px (from 1700 to 2000)
    final fadeProgress = ((scrollOffset - fadeStartOffset) / fadeDistance)
        .clamp(0.0, 1.0);

    // Apply smooth easing for ultra-smooth fade
    final smoothFadeProgress = _easeOutCubic(fadeProgress);

    // Return opacity from 1.0 to 0.0
    return (1.0 - smoothFadeProgress).clamp(0.0, 1.0);
  }

  double _getTextOpacity() {
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    // Show text after scrolling 1000px
    const double textShowOffset = 1000.0;
    // Fade in over 100px for smooth appearance
    const double fadeInDistance = 100.0;

    if (scrollOffset < textShowOffset) {
      return 0.0;
    }

    // Fade in over 100px
    final fadeProgress = ((scrollOffset - textShowOffset) / fadeInDistance)
        .clamp(0.0, 1.0);

    // Apply smooth easing for fade in
    final smoothFadeProgress = _easeInOutCubic(fadeProgress);

    return smoothFadeProgress.clamp(0.0, 1.0);
  }

  double _getTextTopPosition() {
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    final screenHeight = MediaQuery.of(context).size.height;
    const double textShowOffset = 1000.0;

    // If text hasn't appeared yet, return bottom position
    if (scrollOffset < textShowOffset) {
      return screenHeight; // Bottom of screen
    }

    // Movement distance: from bottom to center
    // Calculate progress from textShowOffset to end of phase 2 (2000px)
    const double movementEndOffset = 2000.0;
    final movementProgress =
        ((scrollOffset - textShowOffset) / (movementEndOffset - textShowOffset))
            .clamp(0.0, 1.0);

    // Apply smooth easing for movement
    final smoothMovementProgress = _easeInOutCubic(movementProgress);

    // Start at bottom (screenHeight), end at center (screenHeight / 2)
    final bottomPosition = screenHeight * 0.6;
    final centerPosition = screenHeight * 0.3;

    // Interpolate from bottom to center
    return bottomPosition -
        (smoothMovementProgress * (bottomPosition - centerPosition));
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
          // Text above the Earth - appears after scrolling 1500px, moves from bottom to center
          Positioned(
            left: 0,
            right: 0,
            top: _getTextTopPosition(),
            child: IgnorePointer(
              child: Opacity(
                opacity: _getTextOpacity(),
                child: Center(
                  child: Text(
                    'ByG∆ZE',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 135, 135, 135),
                      fontFamily: 'PixelOperatorMono',
                      fontSize: 200,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
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
            child: AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final scrollOffset = _scrollController.hasClients
                    ? _scrollController.offset
                    : 0.0;

                // Use sinusoidal functions for smooth shake
                final time = _shakeController.value * 2 * math.pi;
                final shakeOffset = Offset(
                  math.sin(time * 1.5) * 5, // smooth horizontal wobble
                  math.cos(time) * 5, // smooth vertical wobble
                );

                // Smoothly transition alignment from center to topCenter
                // Phase 1: Normal zoom centered
                // Phase 2+: Zoom from top 50% (Alignment.topCenter)
                Alignment alignment;
                if (scrollOffset <= _maxScrollDistance) {
                  alignment = Alignment.center;
                } else if (scrollOffset <=
                    _maxScrollDistance + _flashScrollDistance) {
                  // Smoothly blend between center and topCenter
                  final blendProgress =
                      ((scrollOffset - _maxScrollDistance) /
                              _flashScrollDistance)
                          .clamp(0.0, 1.0);
                  final smoothBlend = _easeInOutCubic(blendProgress);
                  // Interpolate between center (0.0, 0.0) and topCenter (0.0, -1.0)
                  alignment = Alignment.lerp(
                    Alignment.center,
                    Alignment.topCenter,
                    smoothBlend,
                  )!;
                } else {
                  alignment = Alignment.topCenter;
                }

                final opacity = _getCockpitOpacity();

                return Transform.translate(
                  offset: shakeOffset,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: currentScale,
                      alignment: alignment,
                      child: Image.asset(
                        'assets/cockpit.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
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
