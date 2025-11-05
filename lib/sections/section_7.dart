import 'package:flutter/material.dart';
import 'dart:ui' as ui show PathMetric, Tangent;

class Section7 extends StatefulWidget {
  const Section7({super.key});

  @override
  State<Section7> createState() => _Section7State();
}

class _Section7State extends State<Section7> {
  // Helper method to find the path offset for a specific position
  double _findPathOffset(Size size, double targetX, double targetY) {
    final Path path = _buildHeartPath(size);
    final List<ui.PathMetric> metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return 0.0;
    final ui.PathMetric metric = metrics.first;
    final double length = metric.length;

    double closestOffset = 0.0;
    double minDistance = double.infinity;
    const int samples = 400;

    for (int i = 0; i <= samples; i++) {
      final double offset = (i / samples) * length;
      final ui.Tangent? tangent = metric.getTangentForOffset(offset);
      if (tangent != null) {
        final double x = tangent.position.dx;
        final double y = tangent.position.dy;

        final double distance =
            ((x - targetX) * (x - targetX) + (y - targetY) * (y - targetY));
        if (distance < minDistance) {
          minDistance = distance;
          closestOffset = offset;
        }
      }
    }

    return closestOffset;
  }

  // Build path for left side only (from center top to bottom via top left)
  Path _buildLeftSidePath(Size size) {
    final Path fullPath = _buildHeartPath(size);
    final List<ui.PathMetric> metrics = fullPath.computeMetrics().toList();
    if (metrics.isEmpty) return fullPath;
    final ui.PathMetric metric = metrics.first;
    final double length = metric.length;

    // Find offsets: center top, top left, and bottom
    final double centerTopX = size.width * 0.5000000;
    final double centerTopY = size.height * 0.2500079;
    final double bottomX = size.width * 0.5;
    final double bottomY = size.height * 0.8335917; // Maximum y in the path

    final double centerTopOffset = _findPathOffset(
      size,
      centerTopX,
      centerTopY,
    );
    final double bottomOffset = _findPathOffset(size, bottomX, bottomY);

    // Extract path from center top to bottom (going through top left)
    if (centerTopOffset < bottomOffset) {
      return metric.extractPath(centerTopOffset, bottomOffset);
    } else {
      // If path loops, combine segments
      final Path segment1 = metric.extractPath(centerTopOffset, length);
      final Path segment2 = metric.extractPath(0, bottomOffset);
      return Path.combine(PathOperation.union, segment1, segment2);
    }
  }

  // Build path for right side only (from center top to bottom via top right)
  Path _buildRightSidePath(Size size) {
    final Path fullPath = _buildHeartPath(size);
    final List<ui.PathMetric> metrics = fullPath.computeMetrics().toList();
    if (metrics.isEmpty) return fullPath;
    final ui.PathMetric metric = metrics.first;
    final double length = metric.length;

    // Find offsets: center top (at end), bottom, and top right
    // Path order: centerTop(start @ ~0) → topLeft → bottom → topRight → centerTop(end @ ~length)
    // For right side: we want centerTop → topRight → bottom
    // We extract: bottom → topRight → centerTop(end)
    // Then reverse animation to get: centerTop → topRight → bottom
    final double centerTopX = size.width * 0.5000000;
    final double centerTopY = size.height * 0.2500079;
    final double bottomX = size.width * 0.5;
    final double bottomY = size.height * 0.8335917;

    final double bottomOffset = _findPathOffset(size, bottomX, bottomY);

    // Find centerTop at the END of the path (near length)
    // Sample the last portion of the path to find where it returns to centerTop
    double centerTopEndOffset = length;
    double minDistance = double.infinity;
    const int samples = 200;
    for (int i = 0; i <= samples; i++) {
      final double offset =
          length - (i / samples) * (length * 0.15); // Check last 15% of path
      final ui.Tangent? tangent = metric.getTangentForOffset(offset);
      if (tangent != null) {
        final double x = tangent.position.dx;
        final double y = tangent.position.dy;
        final double distance =
            ((x - centerTopX) * (x - centerTopX) +
            (y - centerTopY) * (y - centerTopY));
        if (distance < minDistance) {
          minDistance = distance;
          centerTopEndOffset = offset;
        }
      }
    }

    // Extract path from bottom → topRight → centerTop(end)
    // This will be reversed in animation to get: centerTop → topRight → bottom
    if (bottomOffset < centerTopEndOffset) {
      return metric.extractPath(bottomOffset, centerTopEndOffset);
    } else {
      // Handle wrapping case (shouldn't happen, but just in case)
      final Path segment1 = metric.extractPath(bottomOffset, length);
      final Path segment2 = metric.extractPath(0, centerTopEndOffset);
      return Path.combine(PathOperation.union, segment1, segment2);
    }
  }

  Path _buildHeartPath(Size size) {
    final Path path_0 = Path();
    path_0.moveTo(size.width * 0.5000000, size.height * 0.2500079);
    path_0.cubicTo(
      size.width * 0.4250250,
      size.height * 0.1626321,
      size.width * 0.2997404,
      size.height * 0.1356292,
      size.width * 0.2058013,
      size.height * 0.2156392,
    );
    path_0.cubicTo(
      size.width * 0.1118617,
      size.height * 0.2956492,
      size.width * 0.09863625,
      size.height * 0.4294208,
      size.width * 0.1724075,
      size.height * 0.5240500,
    );
    path_0.cubicTo(
      size.width * 0.2337433,
      size.height * 0.6027250,
      size.width * 0.4193667,
      size.height * 0.7686625,
      size.width * 0.4802042,
      size.height * 0.8223708,
    );
    path_0.cubicTo(
      size.width * 0.4870083,
      size.height * 0.8283792,
      size.width * 0.4904125,
      size.height * 0.8313833,
      size.width * 0.4943833,
      size.height * 0.8325625,
    );
    path_0.cubicTo(
      size.width * 0.4978458,
      size.height * 0.8335917,
      size.width * 0.5016375,
      size.height * 0.8335917,
      size.width * 0.5051042,
      size.height * 0.8325625,
    );
    path_0.cubicTo(
      size.width * 0.5090750,
      size.height * 0.8313833,
      size.width * 0.5124750,
      size.height * 0.8283792,
      size.width * 0.5192833,
      size.height * 0.8223708,
    );
    path_0.cubicTo(
      size.width * 0.5801208,
      size.height * 0.7686625,
      size.width * 0.7657417,
      size.height * 0.6027250,
      size.width * 0.8270792,
      size.height * 0.5240500,
    );
    path_0.cubicTo(
      size.width * 0.9008500,
      size.height * 0.4294208,
      size.width * 0.8892375,
      size.height * 0.2948075,
      size.width * 0.7936833,
      size.height * 0.2156392,
    );
    path_0.cubicTo(
      size.width * 0.6981292,
      size.height * 0.1364708,
      size.width * 0.5749750,
      size.height * 0.1626321,
      size.width * 0.5000000,
      size.height * 0.2500079,
    );
    path_0.close();

    return path_0;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final widgetSize = Size(screenSize.width * 0.8, screenSize.height * 0.8);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: widgetSize.width,
          height: widgetSize.height,
          child: OverflowBox(
            minWidth: widgetSize.width,
            minHeight: widgetSize.height,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: SizedBox(
              width: widgetSize.width,
              height: widgetSize.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // L1 - Travels only on left side (from center top to bottom via top left)
                  CustomLaserPathFollower(
                    size: widgetSize,
                    pathBuilder: _buildLeftSidePath,
                    color: const Color(0xFFFF0066), // Bright red/pink
                    thickness: 3,
                    duration: const Duration(seconds: 3),
                    trailLength: 400,
                    bidirectionalTrail: true,
                    showBasePath: false,
                    progressOffset: 0.0,
                  ),
                  // L2 - Travels only on right side (from center top to bottom via top right)
                  // Note: right side path is extracted bottom→centerTop (includes topRight),
                  // so we reverse direction to get centerTop→topRight→bottom
                  CustomLaserPathFollower(
                    size: widgetSize,
                    pathBuilder: _buildRightSidePath,
                    color: const Color(0xFFFF0066), // Bright red/pink
                    thickness: 3,
                    duration: const Duration(seconds: 3),
                    trailLength: 400,
                    bidirectionalTrail: true,
                    showBasePath: false,
                    progressOffset: 0.0,
                    reverseDirection:
                        true, // Reverse to get centerTop→topRight→bottom
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Laser Path Follower with progress offset support
class CustomLaserPathFollower extends StatefulWidget {
  const CustomLaserPathFollower({
    super.key,
    required this.size,
    required this.pathBuilder,
    this.color = const Color.fromARGB(255, 255, 0, 0),
    this.thickness = 6,
    this.duration = const Duration(seconds: 5),
    this.trailLength = 400,
    this.bidirectionalTrail = true,
    this.showBasePath = false,
    this.progressOffset = 0.0,
    this.reverseDirection = false,
  });

  final Size size;
  final Path Function(Size size) pathBuilder;
  final Color color;
  final double thickness;
  final Duration duration;
  final double trailLength;
  final bool bidirectionalTrail;
  final bool showBasePath;
  final double progressOffset; // Offset from 0.0 to 1.0
  final bool reverseDirection; // If true, animation moves backwards

  @override
  State<CustomLaserPathFollower> createState() =>
      _CustomLaserPathFollowerState();
}

class _CustomLaserPathFollowerState extends State<CustomLaserPathFollower>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant CustomLaserPathFollower oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller
        ..duration = widget.duration
        ..reset()
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ClipRect(
          clipBehavior: Clip.none, // Allow laser blur to extend beyond bounds
          child: CustomPaint(
            size: widget.size,
            painter: _CustomLaserPainter(
              progress: widget.reverseDirection
                  ? (1.0 - _controller.value + widget.progressOffset) % 1.0
                  : (_controller.value + widget.progressOffset) % 1.0,
              color: widget.color,
              thickness: widget.thickness,
              trailLength: widget.trailLength,
              bidirectionalTrail: widget.bidirectionalTrail,
              showBasePath: widget.showBasePath,
              pathBuilder: widget.pathBuilder,
            ),
          ),
        );
      },
    );
  }
}

class _CustomLaserPainter extends CustomPainter {
  _CustomLaserPainter({
    required this.progress,
    required this.color,
    required this.thickness,
    required this.trailLength,
    required this.bidirectionalTrail,
    required this.showBasePath,
    required this.pathBuilder,
  });

  final double progress; // 0..1
  final Color color;
  final double thickness;
  final double trailLength;
  final bool bidirectionalTrail;
  final bool showBasePath;
  final Path Function(Size size) pathBuilder;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = pathBuilder(size);
    final List<ui.PathMetric> metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final ui.PathMetric metric = metrics.first;
    final double length = metric.length;
    if (length <= 0) return;

    final double clampedTrail = trailLength.clamp(0.0, length * 0.99);
    final double end = (progress.clamp(0.0, 1.0)) * length;
    final double start = end - clampedTrail;

    // Base path (subtle) to indicate the route
    if (showBasePath) {
      final Paint basePaint = Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness * 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, basePaint);
    }

    // isolate additive blending to avoid platform artifacts
    // Expand bounds to allow for blur overflow
    const double blurPadding = 100.0;
    final Rect expandedBounds = Rect.fromLTWH(
      -blurPadding,
      -blurPadding,
      size.width + blurPadding * 2,
      size.height + blurPadding * 2,
    );
    canvas.saveLayer(expandedBounds, Paint());

    void drawSegment(double a, double b, {required bool brightenTowardsEnd}) {
      const double eps = 0.001; // avoid degenerate subpaths
      final double aa = a.clamp(0.0, length);
      final double bb = b.clamp(0.0, length);
      if (bb <= aa + eps) return;

      // Slice the segment into small pieces with a fade, which smooths corners/joins
      const int slices = 20;
      final double segLen = bb - aa;
      final double step = segLen / slices;

      for (int k = 0; k < slices; k++) {
        final double sa = aa + step * k;
        final double sb = k == slices - 1 ? bb : (aa + step * (k + 1));
        if (sb <= sa + eps) continue;

        // brightness peaks at the head. If brightenTowardsEnd, head is near bb; else near aa
        final double t = brightenTowardsEnd
            ? ((k + 1) / slices)
            : (1.0 - (k / slices));
        final double fade = t * t; // quadratic falloff

        final Path sub = metric.extractPath(sa, sb);

        final Paint outerGlow = Paint()
          ..color = color.withOpacity(0.7 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness * 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16)
          ..blendMode = BlendMode.plus;

        final Paint midGlow = Paint()
          ..color = color.withOpacity(0.9 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness * 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
          ..blendMode = BlendMode.plus;

        final Paint core = Paint()
          ..color = color.withOpacity(1.0 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..blendMode = BlendMode.plus;

        canvas.drawPath(sub, outerGlow);
        canvas.drawPath(sub, midGlow);
        canvas.drawPath(sub, core);
      }
    }

    // Backward trail (behind head)
    if (start >= 0) {
      drawSegment(start, end, brightenTowardsEnd: true);
    } else {
      drawSegment(length + start, length, brightenTowardsEnd: true);
      drawSegment(0, end, brightenTowardsEnd: true);
    }

    // Forward trail (ahead of head) if enabled
    if (bidirectionalTrail) {
      final double endForward = end + clampedTrail;
      if (endForward <= length) {
        drawSegment(end, endForward, brightenTowardsEnd: false);
      } else {
        drawSegment(end, length, brightenTowardsEnd: false);
        drawSegment(0, endForward - length, brightenTowardsEnd: false);
      }
    }

    // Draw a bright traveling head dot
    final ui.Tangent? t = metric.getTangentForOffset(end.clamp(0.0, length));
    if (t != null) {
      final Paint headOuter = Paint()
        ..color = color.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
        ..blendMode = BlendMode.plus;
      final Paint headCore = Paint()
        ..color = color.withOpacity(1.0)
        ..blendMode = BlendMode.plus;

      canvas.drawCircle(t.position, thickness * 1.6, headOuter);
      canvas.drawCircle(t.position, thickness * 0.7, headCore);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CustomLaserPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.trailLength != trailLength ||
        oldDelegate.bidirectionalTrail != bidirectionalTrail ||
        oldDelegate.showBasePath != showBasePath ||
        oldDelegate.pathBuilder != pathBuilder;
  }
}
