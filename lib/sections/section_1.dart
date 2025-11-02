import 'package:flutter/material.dart';
import 'package:lazer_widgets/backgrounds/stars_background.dart';

class Section1 extends StatelessWidget {
  const Section1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // background image
          Positioned.fill(
            child: Image.asset('assets/cockpit.png', fit: BoxFit.cover),
          ),
          // Stars background
          const StarsBackground(
            starCount: 200,
            minStarSize: 1.0,
            maxStarSize: 3.0,
            starColor: Colors.white,
            twinkleSpeed: 30.0,
            scrollSpeed: 0.9,
          ),
          // Shooting star on top
          // Center(child: CenterShootingStar()),
        ],
      ),
    );
  }
}
