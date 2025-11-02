import 'package:flutter/material.dart';
import 'package:lazer_widgets/box/widgets/lazer_path_follower_widget.dart';

class Section2 extends StatefulWidget {
  const Section2({super.key});

  @override
  State<Section2> createState() => _Section2State();
}

class _Section2State extends State<Section2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose what\'s right for you',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _PortraitLazerBox(width: 400, height: 600),
                  const SizedBox(width: 40),
                  const _PortraitLazerBox(width: 400, height: 600),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortraitLazerBox extends StatefulWidget {
  final double width;
  final double height;

  const _PortraitLazerBox({required this.width, required this.height});

  @override
  State<_PortraitLazerBox> createState() => _PortraitLazerBoxState();
}

class _PortraitLazerBoxState extends State<_PortraitLazerBox> {
  @override
  Widget build(BuildContext context) {
    final double radius = widget.width * 0.033;
    const double thickness = 2;

    final double innerContainerWidth = widget.width * 0.9;
    final double innerContainerHeight = widget.height * 0.9;
    final double outerContainerWidth = widget.width * 0.93;
    final double outerContainerHeight = widget.height * 0.93;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base box
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: innerContainerWidth,
                height: innerContainerHeight,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(83, 35, 35, 35),
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              Container(
                width: outerContainerWidth,
                height: outerContainerHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ],
          ),
          // First laser overlay following the rounded rectangle border
          Positioned.fill(
            child: IgnorePointer(
              child: LazerPathFollowerWidget(
                showBasePath: false,
                color: const Color.fromARGB(255, 40, 99, 208),
                coreColors: const [
                  Color.fromARGB(255, 110, 161, 255),
                  Color.fromARGB(255, 70, 57, 255),
                ],
                thickness: thickness,
                duration: const Duration(seconds: 8),
                bidirectionalTrail: true,
                trailLength: 120,
                pathBuilder: (size) {
                  // Calculate the border position to match the inner container
                  final double borderOffsetX =
                      (size.width - innerContainerWidth) / 2;
                  final double borderOffsetY =
                      (size.height - innerContainerHeight) / 2;
                  // The path should follow the border line exactly
                  final Rect rect = Rect.fromLTWH(
                    borderOffsetX,
                    borderOffsetY,
                    innerContainerWidth,
                    innerContainerHeight,
                  );
                  return Path()
                    ..addRRect(RRect.fromRectXY(rect, radius, radius));
                },
              ),
            ),
          ),
          // Second laser overlay - different color and offset for symmetry
          Positioned.fill(
            child: IgnorePointer(
              child: LazerPathFollowerWidget(
                showBasePath: false,
                color: const Color.fromARGB(255, 255, 100, 100),
                coreColors: const [
                  Color.fromARGB(255, 255, 150, 150),
                  Color.fromARGB(255, 255, 50, 50),
                ],
                thickness: thickness,
                duration: const Duration(seconds: 8),
                bidirectionalTrail: true,
                trailLength: 120,
                progressOffset: 0.5,
                pathBuilder: (size) {
                  // Calculate the border position to match the inner container
                  final double borderOffsetX =
                      (size.width - innerContainerWidth) / 2;
                  final double borderOffsetY =
                      (size.height - innerContainerHeight) / 2;
                  // The path should follow the border line exactly
                  final Rect rect = Rect.fromLTWH(
                    borderOffsetX,
                    borderOffsetY,
                    innerContainerWidth,
                    innerContainerHeight,
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
