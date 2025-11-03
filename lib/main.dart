import 'package:flutter/material.dart';
import 'package:lazer_widgets/sections/section_5.dart';

void main() {
  runApp(const LazerWidgets());
}

class LazerWidgets extends StatefulWidget {
  const LazerWidgets({super.key});

  @override
  State<LazerWidgets> createState() => _LazerWidgetsState();
}

class _LazerWidgetsState extends State<LazerWidgets> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Section 1 with its own scroll handling
            Section5(),
          ],
        ),
      ),
    );
  }
}
