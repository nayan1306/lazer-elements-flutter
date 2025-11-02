import 'package:flutter/material.dart';
import 'package:lazer_widgets/circle/widgets/dual_circle_lazer_follower.dart';

class CircleLazer extends StatefulWidget {
  const CircleLazer({super.key});

  @override
  State<CircleLazer> createState() => _CircleLazerState();
}

class _CircleLazerState extends State<CircleLazer> {
  LazerDirection _firstLazerDirection = LazerDirection.clockwise;
  LazerDirection _secondLazerDirection = LazerDirection.counterClockwise;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;

    // Use 80% of the smaller dimension, with a max of 600 and min of 200
    final double baseSize =
        (screenWidth < screenHeight ? screenWidth : screenHeight) * 0.8;
    final double circleSize = baseSize.clamp(200.0, 600.0);

    const double thickness = 3;

    // Scale inner container sizes proportionally
    final double innerContainerSize = circleSize * 0.9; // 540/600 = 0.9
    final double outerContainerSize = circleSize * (560 / 600); // 560/600 ratio

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Direction controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Lazer 1: ',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  ToggleButtons(
                    isSelected: [
                      _firstLazerDirection == LazerDirection.clockwise,
                      _firstLazerDirection == LazerDirection.counterClockwise,
                    ],
                    onPressed: (index) {
                      setState(() {
                        _firstLazerDirection = index == 0
                            ? LazerDirection.clockwise
                            : LazerDirection.counterClockwise;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    fillColor: const Color.fromARGB(255, 40, 99, 208),
                    color: Colors.white70,
                    constraints: const BoxConstraints(
                      minHeight: 36,
                      minWidth: 80,
                    ),
                    children: const [Text('Clockwise'), Text('Counter')],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Lazer 2: ',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  ToggleButtons(
                    isSelected: [
                      _secondLazerDirection == LazerDirection.clockwise,
                      _secondLazerDirection == LazerDirection.counterClockwise,
                    ],
                    onPressed: (index) {
                      setState(() {
                        _secondLazerDirection = index == 0
                            ? LazerDirection.clockwise
                            : LazerDirection.counterClockwise;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    fillColor: const Color.fromARGB(255, 40, 99, 208),
                    color: Colors.white70,
                    constraints: const BoxConstraints(
                      minHeight: 36,
                      minWidth: 80,
                    ),
                    children: const [Text('Clockwise'), Text('Counter')],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Circle lazer widget
        SizedBox(
          width: circleSize,
          height: circleSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Base circle
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: innerContainerSize,
                    height: innerContainerSize,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(83, 35, 35, 35),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: outerContainerSize,
                    height: outerContainerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                  ),
                ],
              ),
              // Dual laser overlay following the circle border
              // Two lazers going in opposite directions (top to bottom and bottom to top)
              Positioned.fill(
                child: IgnorePointer(
                  child: DualCircleLazerFollower(
                    showBasePath: false,
                    color: const Color.fromARGB(255, 208, 40, 40),
                    coreColors: [
                      const Color.fromARGB(255, 255, 183, 77),
                      const Color.fromARGB(255, 255, 112, 67),
                    ],
                    thickness: thickness,
                    duration: const Duration(seconds: 4),
                    bidirectionalTrail: true,
                    trailLength: 200, // can be tuned or computed below
                    firstLazerDirection: _firstLazerDirection,
                    secondLazerDirection: _secondLazerDirection,
                    pathBuilder: (size) {
                      // Calculate the border position to match the outer container
                      // The outer container is centered, so calculate the offset
                      final double borderOffset =
                          (size.width - outerContainerSize) / 2;
                      // The path should follow the border line exactly
                      // Position the path circle at the border offset with the container size
                      // The stroke is centered on the path, so it will align with the border
                      final Rect rect = Rect.fromLTWH(
                        borderOffset,
                        borderOffset,
                        outerContainerSize,
                        outerContainerSize,
                      );
                      return Path()..addOval(rect);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
