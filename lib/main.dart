import 'package:flutter/material.dart';
import 'package:lazer_widgets/sections/section_1.dart';
import 'package:lazer_widgets/sections/section_2.dart';

void main() {
  runApp(const LazerWidgets());
}

class LazerWidgets extends StatefulWidget {
  const LazerWidgets({super.key});

  @override
  State<LazerWidgets> createState() => _LazerWidgetsState();
}

class _LazerWidgetsState extends State<LazerWidgets> {
  double _flashProgress = 0.0;

  void _handleFlashProgress(double progress) {
    setState(() {
      _flashProgress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Section 1 with its own scroll handling
            Section1(onScrollProgress: _handleFlashProgress),
          ],
        ),
      ),
    );
  }
}
