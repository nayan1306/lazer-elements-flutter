import 'package:flutter/material.dart';
import 'package:lazer_widgets/sections/section_1.dart';
import 'package:lazer_widgets/sections/section_2.dart';
import 'package:lazer_widgets/sections/section_3.dart';
import 'package:lazer_widgets/sections/section_4.dart';
import 'package:lazer_widgets/sections/section_5.dart';

class Section extends StatelessWidget {
  const Section({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Section 1
            SizedBox(height: screenHeight, child: const Section1()),
            // Section 2
            SizedBox(height: screenHeight * 1.2, child: const Section2()),
            // Section 3
            SizedBox(height: screenHeight * 1.2, child: const Section3()),
            // Section 4
            SizedBox(height: screenHeight, child: const Section4()),
            // Section 5
            SizedBox(height: screenHeight, child: const Section5()),
          ],
        ),
      ),
    );
  }
}
