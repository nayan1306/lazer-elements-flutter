import 'package:flutter/material.dart';
import 'package:lazer_widgets/box/widgets/lazer_path_follower_widget.dart';

class LazerBox extends StatelessWidget {
  const LazerBox({super.key});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;

    // Use 80% of the smaller dimension, with a max of 600 and min of 200
    final double baseSize =
        (screenWidth < screenHeight ? screenWidth : screenHeight) * 0.8;
    final double boxSize = baseSize.clamp(200.0, 600.0);

    // Scale radius proportionally (was 20 for 600, so ~3.33% of box size)
    final double radius = boxSize * 0.033;
    const double thickness = 3;

    // Scale inner container sizes proportionally
    final double innerContainerSize = boxSize * 0.9; // 540/600 = 0.9
    final double outerContainerSize = boxSize * (560 / 600); // 560/600 ratio

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base box
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: innerContainerSize,
                height: innerContainerSize,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(83, 35, 35, 35),
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              Container(
                width: outerContainerSize,
                height: outerContainerSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
              ),
            ],
          ),
          // Laser overlay following the rounded rectangle border
          Positioned.fill(
            child: IgnorePointer(
              child: LazerPathFollowerWidget(
                showBasePath: false,
                color: const Color.fromARGB(255, 40, 99, 208),
                coreColors: [
                  const Color.fromARGB(255, 110, 161, 255),
                  const Color.fromARGB(255, 70, 57, 255),
                ],
                thickness: thickness,
                duration: const Duration(seconds: 8),
                bidirectionalTrail: true,
                trailLength: 120, // can be tuned or computed below
                pathBuilder: (size) {
                  // Calculate the border position to match the outer container
                  // The outer container is centered, so calculate the offset
                  final double borderOffset =
                      (size.width - outerContainerSize) / 2;
                  // The path should follow the border line exactly
                  // Position the path rectangle at the border offset with the container size
                  // The stroke is centered on the path, so it will align with the border
                  final Rect rect = Rect.fromLTWH(
                    borderOffset,
                    borderOffset,
                    outerContainerSize,
                    outerContainerSize,
                  );
                  return Path()
                    ..addRRect(RRect.fromRectXY(rect, radius, radius));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
