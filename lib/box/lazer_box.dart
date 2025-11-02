import 'package:flutter/material.dart';
import 'package:lazer_widgets/box/widgets/lazer_path_follower_widget.dart';

class LazerBox extends StatelessWidget {
  const LazerBox({super.key});

  @override
  Widget build(BuildContext context) {
    const double radius = 20;
    const double thickness = 3;
    const double outerBlur = 16;
    final double safeMargin = (outerBlur + thickness * 2)
        .clamp(20, 32)
        .toDouble();
    return SizedBox(
      width: 600,
      height: 600,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base box
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 540,
                height: 540,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(83, 35, 35, 35),
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              Container(
                width: 560,
                height: 560,
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
                  // Inset so glow is not clipped at edges
                  final double inset = safeMargin;
                  final Rect rect = Rect.fromLTWH(
                    inset,
                    inset,
                    size.width - inset * 2,
                    size.height - inset * 2,
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
