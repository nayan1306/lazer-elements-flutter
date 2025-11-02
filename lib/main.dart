import 'package:flutter/material.dart';
import 'package:lazer_widgets/sections/section_1.dart';
import 'package:lazer_widgets/sections/section_2.dart';

void main() {
  runApp(const LazerWidgets());
}

class LazerWidgets extends StatelessWidget {
  const LazerWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const Scaffold(backgroundColor: Colors.black, body: Section2()),
    );
  }
}
