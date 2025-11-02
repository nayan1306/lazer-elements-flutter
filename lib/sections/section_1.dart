import 'package:flutter/material.dart';
import 'package:lazer_widgets/shooting_star/shooting_star.dart';
import 'package:lazer_widgets/backgrounds/stars_background.dart';

class Section1 extends StatefulWidget {
  const Section1({super.key});

  @override
  State<Section1> createState() => _Section1State();
}

class _Section1State extends State<Section1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Stars background
          const StarsBackground(
            starCount: 200,
            minStarSize: 1.0,
            maxStarSize: 3.0,
            starColor: Colors.white,
            twinkleSpeed: 30.0,
          ),
          // Shooting star on top
          Center(child: CenterShootingStar()),
        ],
      ),
    );
  }
}
