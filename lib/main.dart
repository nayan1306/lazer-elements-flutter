import 'package:flutter/material.dart';
import 'package:lazer_widgets/shooting_star/shooting_star.dart';

void main() {
  runApp(const LazerWidgets());
}

class LazerWidgets extends StatelessWidget {
  const LazerWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CenterShootingStar()),
      ),
    );
  }
}
