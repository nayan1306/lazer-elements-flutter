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

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // background image with shake/tremble effect
          Positioned.fill(
            child: Transform.scale(
              scale: 1.1, // Zoom in by 20%
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
        ],
      ),
    );
  }
}
