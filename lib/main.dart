import 'package:flutter/material.dart';
import 'package:lazer_widgets/circle/circle_lazer.dart';

void main() {
  runApp(const LazerWidgets());
}

class LazerWidgets extends StatelessWidget {
  const LazerWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircleLazer()),
      ),
    );
  }
}
