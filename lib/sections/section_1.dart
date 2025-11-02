import 'package:flutter/material.dart';
import 'package:lazer_widgets/shooting_star/shooting_star.dart';

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
      body: Center(child: CenterShootingStar()),
    );
  }
}
