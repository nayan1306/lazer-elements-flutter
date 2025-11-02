import 'package:flutter/material.dart';
import 'package:lazer_widgets/lazers/shooting_star_path_follower.dart';

/// A shooting star that starts from the center and follows a curved path
/// extending to both ends of the screen with two laser trails
class CenterShootingStar extends StatelessWidget {
  const CenterShootingStar({
    super.key,
    this.color = const Color.fromARGB(255, 255, 106, 0),
    this.headColor = const Color.fromARGB(255, 255, 76, 76),
    this.thickness = 3,
    this.duration = const Duration(seconds: 2),
    this.trailLength = 150,
    this.showBasePath = false,
  });

  final Color color;
  final Color?
  headColor; // Optional head color, defaults to white if not specified
  final double thickness;
  final Duration duration;
  final double trailLength;
  final bool showBasePath;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive trail length based on screen diagonal
        final screenDiagonal = constraints.maxWidth + constraints.maxHeight;
        final responsiveTrailLength = (trailLength / 800) * screenDiagonal;

        return Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Left trail
              ShootingStarPathFollower(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                color: color,
                headColor: headColor,
                thickness: thickness,
                duration: duration,
                trailLength: responsiveTrailLength,
                showBasePath: showBasePath,
                backgroundColor: Colors.transparent,
                pathBuilder: (size) {
                  final path = Path();
                  final centerX = size.width / 2;
                  final startY = size.height * 0.25; // Start near top center

                  // Start from near top center
                  path.moveTo(centerX, startY);

                  // Continuous curved path from center to edge
                  path.cubicTo(
                    centerX * 0.7,
                    size.height * 0.55, // cp1: downward curve
                    centerX * 0.4,
                    size.height * 0.65, // cp2: circular arc downward
                    centerX * 0.2,
                    size.height * 0.7, // transition point
                  );

                  // Continue the curve smoothly to the edge
                  path.cubicTo(
                    centerX * 0.1,
                    size.height * 0.72, // cp1: continues curve
                    size.width * 0.05,
                    size.height * 0.73, // cp2: ends curve
                    0, // end point
                    size.height * 0.75, // end point
                  );

                  return path;
                },
              ),
              // Right trail (mirror symmetric)
              ShootingStarPathFollower(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                color: color,
                headColor: headColor,
                thickness: thickness,
                duration: duration,
                trailLength: responsiveTrailLength,
                showBasePath: showBasePath,
                backgroundColor: Colors.transparent,
                pathBuilder: (size) {
                  final path = Path();
                  final centerX = size.width / 2;
                  final startY = size.height * 0.25; // Start near top center

                  // Start from near top center
                  path.moveTo(centerX, startY);

                  // Continuous curved path from center to edge
                  // Mirror symmetric to left trail
                  path.cubicTo(
                    centerX * 1.3,
                    size.height * 0.55, // cp1: downward curve
                    centerX * 1.6,
                    size.height * 0.65, // cp2: circular arc downward
                    centerX * 1.8,
                    size.height * 0.7, // transition point
                  );

                  // Continue the curve smoothly to the edge
                  path.cubicTo(
                    centerX * 1.9,
                    size.height * 0.72, // cp1: continues curve
                    size.width * 0.95,
                    size.height * 0.73, // cp2: ends curve
                    size.width, // end point
                    size.height * 0.75, // end point
                  );

                  return path;
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
