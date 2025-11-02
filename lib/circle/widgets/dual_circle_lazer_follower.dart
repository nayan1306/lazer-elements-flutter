import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'dart:ui' as ui show PathMetric, Tangent;

/// Direction enum for lazer movement
enum LazerDirection { clockwise, counterClockwise }

/// A dual laser path follower widget that animates two lazers in opposite directions.
class DualCircleLazerFollower extends StatefulWidget {
  const DualCircleLazerFollower({
    super.key,
    this.color = const Color(0xFF00E5FF),
    this.coreColor = Colors.white,
    this.glowColors,
    this.coreColors,
    this.thickness = 3,
    this.duration = const Duration(seconds: 6),
    this.trailLength = 80,
    this.bidirectionalTrail = true,
    this.showBasePath = true,
    this.backgroundColor,
    this.firstLazerDirection = LazerDirection.clockwise,
    this.secondLazerDirection = LazerDirection.counterClockwise,
    required this.pathBuilder,
  });

  final Color color;
  final Color coreColor;
  final List<Color>? glowColors;
  final List<Color>? coreColors;
  final double thickness;
  final Duration duration;
  final double trailLength;
  final bool bidirectionalTrail;
  final bool showBasePath;
  final Color? backgroundColor;
  final LazerDirection firstLazerDirection;
  final LazerDirection secondLazerDirection;
  final Path Function(Size size) pathBuilder;

  @override
  State<DualCircleLazerFollower> createState() =>
      _DualCircleLazerFollowerState();
}

class _DualCircleLazerFollowerState extends State<DualCircleLazerFollower>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant DualCircleLazerFollower oldWidget) {
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
    Widget child = LayoutBuilder(
      builder: (context, constraints) {
        final Size size = constraints.biggest;

        return SizedBox(
          width: size.width,
          height: size.height,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _DualLaserPainter(
                    progress: _controller.value,
                    color: widget.color,
                    coreColor: widget.coreColor,
                    glowColors: widget.glowColors,
                    coreColors: widget.coreColors,
                    thickness: widget.thickness,
                    trailLength: widget.trailLength,
                    bidirectionalTrail: widget.bidirectionalTrail,
                    showBasePath: widget.showBasePath,
                    firstLazerDirection: widget.firstLazerDirection,
                    secondLazerDirection: widget.secondLazerDirection,
                    pathBuilder: widget.pathBuilder,
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (widget.backgroundColor != null) {
      child = DecoratedBox(
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: child,
      );
    }

    return child;
  }
}

class _DualLaserPainter extends CustomPainter {
  _DualLaserPainter({
    required this.progress,
    required this.color,
    required this.coreColor,
    required this.glowColors,
    required this.coreColors,
    required this.thickness,
    required this.trailLength,
    required this.bidirectionalTrail,
    required this.showBasePath,
    required this.firstLazerDirection,
    required this.secondLazerDirection,
    required this.pathBuilder,
  });

  final double progress; // 0..1
  final Color color;
  final Color coreColor;
  final List<Color>? glowColors;
  final List<Color>? coreColors;
  final double thickness;
  final double trailLength;
  final bool bidirectionalTrail;
  final bool showBasePath;
  final LazerDirection firstLazerDirection;
  final LazerDirection secondLazerDirection;
  final Path Function(Size size) pathBuilder;

  // Helper to normalize progress value (handle negative modulo)
  static double normalizeProgress(double p) {
    // Validate input is finite
    if (!p.isFinite) return 0.0;
    double r = p % 1.0;
    if (r < 0) r += 1.0;
    // Ensure result is valid
    return r.clamp(0.0, 1.0);
  }

  // Helper to draw a single lazer
  void _drawLaser(
    Canvas canvas,
    ui.PathMetric metric,
    double length,
    double normalizedProgress, {
    bool reverse = false,
  }) {
    // Validate inputs
    if (!length.isFinite || length <= 0) return;
    if (!normalizedProgress.isFinite) return;

    final double clampedTrail = trailLength.clamp(0.0, length * 0.99);
    // normalizedProgress is already calculated correctly for the direction
    // (decreasing for counter-clockwise, increasing for clockwise)
    // So we just use it directly
    final double end = (normalizedProgress.clamp(0.0, 1.0)) * length;

    // Validate end position
    if (!end.isFinite) return;

    final double back = clampedTrail;
    final double front = bidirectionalTrail ? clampedTrail : 0.0;
    final double totalSpan = back + front;

    if (totalSpan > 0) {
      final int slices = (totalSpan / math.max(2.0, thickness * 1.6))
          .clamp(70, 150)
          .round();
      final double stepLen = totalSpan / slices;
      final double overlap = stepLen * 0.35;
      const double eps = 0.0001;

      Color _sample(List<Color> colors, double t) {
        if (colors.isEmpty) return Colors.transparent;
        if (colors.length == 1) return colors.first;
        final double x = t.clamp(0.0, 1.0);
        final double pos = x * (colors.length - 1);
        final int i = pos.floor();
        final int j = pos.ceil();
        if (i == j) return colors[i];
        final double f = pos - i;
        return Color.lerp(colors[i], colors[j], f) ?? colors[j];
      }

      double wrap(double o) {
        if (!o.isFinite) return 0.0;
        double r = o % length;
        if (r < 0) r += length;
        // Ensure result is valid
        if (!r.isFinite) return 0.0;
        return r.clamp(0.0, length);
      }

      void drawSub(double a, double b, double fade, double tAlong) {
        // Validate inputs
        if (!a.isFinite || !b.isFinite) return;
        if (b <= a + eps) return;

        // Ensure values are within valid range
        final double safeA = a.clamp(0.0, length);
        final double safeB = b.clamp(0.0, length);
        if (safeB <= safeA + eps) return;

        // Extract path segment - for reverse direction, the positions are already
        // calculated backwards in the calling code, so we extract normally
        final Path sub = metric.extractPath(safeA, safeB);

        final Color glowBase = glowColors != null
            ? _sample(glowColors!, tAlong)
            : color;
        final Color coreBase = coreColors != null
            ? _sample(coreColors!, tAlong)
            : coreColor;

        final Paint outerGlow = Paint()
          ..color = glowBase.withOpacity(0.35 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness * 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16)
          ..blendMode = BlendMode.plus;

        final Paint midGlow = Paint()
          ..color = glowBase.withOpacity(0.6 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness * 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
          ..blendMode = BlendMode.plus;

        final Paint core = Paint()
          ..color = coreBase.withOpacity(1.0 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.round
          ..blendMode = BlendMode.plus;

        canvas.drawPath(sub, outerGlow);
        canvas.drawPath(sub, midGlow);
        if (fade > 0.12) {
          canvas.drawPath(sub, core);
        }
      }

      for (int i = 0; i < slices; i++) {
        // For reverse direction, calculate segments going backwards
        final double localStart = reverse
            ? (back -
                  (i + 1) * stepLen) // Go backwards: from back towards -front
            : (-back + i * stepLen); // Normal: from -back towards front
        final double localEnd = localStart + (reverse ? -stepLen : stepLen);
        final double localCenter = (localStart + localEnd) * 0.5;

        double denom;
        if (localCenter >= 0) {
          denom = front <= 0 ? 1.0 : front;
        } else {
          denom = back <= 0 ? 1.0 : back;
        }
        final double fadeLinear = (1.0 - (localCenter.abs() / denom)).clamp(
          0.0,
          1.0,
        );
        final double fade = fadeLinear * fadeLinear;

        // For reverse, swap start and end to extract backwards
        final double sa = reverse
            ? wrap(end + localEnd - overlap)
            : wrap(end + localStart - overlap);
        final double sb = reverse
            ? wrap(end + localStart + overlap)
            : wrap(end + localEnd + overlap);

        // Validate calculated positions
        if (!sa.isFinite || !sb.isFinite) continue;

        final double tAlong = totalSpan <= 0
            ? 0.5
            : ((localCenter + back) / totalSpan).clamp(0.0, 1.0);

        if (sb > sa) {
          drawSub(sa, sb, fade, tAlong);
        } else if (sa > sb) {
          // Wrap-around case
          drawSub(sa, length, fade, tAlong);
          drawSub(0, sb, fade, tAlong);
        }
      }
    }

    // Head dot
    final double safeEnd = end.clamp(0.0, length);
    if (!safeEnd.isFinite) return;
    final ui.Tangent? t = metric.getTangentForOffset(safeEnd);
    if (t != null && t.position.dx.isFinite && t.position.dy.isFinite) {
      final double tHead = (back + 0.0) / (totalSpan <= 0 ? 1.0 : totalSpan);
      final Color glowHead = glowColors != null
          ? (glowColors!.isNotEmpty
                ? (glowColors!.length == 1
                      ? glowColors!.first
                      : (Color.lerp(
                              glowColors![0],
                              glowColors![glowColors!.length - 1],
                              tHead,
                            ) ??
                            glowColors!.last))
                : color)
          : color;
      final Color coreHead = coreColors != null
          ? (coreColors!.isNotEmpty
                ? (coreColors!.length == 1
                      ? coreColors!.first
                      : (Color.lerp(
                              coreColors![0],
                              coreColors![coreColors!.length - 1],
                              tHead,
                            ) ??
                            coreColor))
                : coreColor)
          : coreColor;

      final Paint headOuter = Paint()
        ..color = glowHead.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
        ..blendMode = BlendMode.plus;
      final Paint headCore = Paint()
        ..color = coreHead
        ..blendMode = BlendMode.plus;

      canvas.drawCircle(t.position, thickness * 1.6, headOuter);
      canvas.drawCircle(t.position, thickness * 0.7, headCore);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Validate size
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0)
      return;

    final Path path = pathBuilder(size);
    final List<ui.PathMetric> metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final ui.PathMetric metric = metrics.first;
    final double length = metric.length;
    if (!length.isFinite || length <= 0) return;

    if (showBasePath) {
      final Paint basePaint = Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness;
      canvas.drawPath(path, basePaint);
    }

    canvas.saveLayer(Offset.zero & size, Paint());

    // First lazer: direction controlled by firstLazerDirection
    final bool firstReverse =
        firstLazerDirection == LazerDirection.counterClockwise;
    // For complete full circle loop:
    // Clockwise: progress 0→1 gives position 0.0→1.0 (full circle forward)
    // Counter-clockwise: progress 0→1 gives position 1.0→0.0 (full circle backward)
    final double firstProgress = firstReverse
        ? normalizeProgress(
            1.0 - progress,
          ) // Counter-clockwise: start at 1.0, go to 0.0
        : progress; // Clockwise: 0.0 to 1.0
    _drawLaser(canvas, metric, length, firstProgress, reverse: firstReverse);

    // Second lazer: direction controlled by secondLazerDirection
    final bool secondReverse =
        secondLazerDirection == LazerDirection.counterClockwise;

    // If lazers are going in opposite directions, offset by half circle (0.5)
    // so they're always on opposite sides and never meet at the same point.
    // For same direction, offset by small amount to avoid initial overlap.
    final bool oppositeDirections = firstReverse != secondReverse;
    final double offset = oppositeDirections ? 0.5 : 0.15;

    // For complete full circle loop with offset:
    // Clockwise with offset: (0.0+offset)→(1.0+offset) = offset→(1.0+offset)
    //   This gives: offset → (offset+1.0) which wraps to offset (full circle)
    // Counter-clockwise with offset: (1.0+offset)→(0.0+offset) = (1.0+offset)→offset
    //   This gives: (1.0+offset) → offset which wraps around (full circle)
    final double secondProgress = secondReverse
        ? normalizeProgress(
            1.0 + offset - progress,
          ) // Counter-clockwise: goes from (1.0+offset) to offset
        : normalizeProgress(
            progress + offset,
          ); // Clockwise: goes from offset to (1.0+offset)
    _drawLaser(canvas, metric, length, secondProgress, reverse: secondReverse);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DualLaserPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.trailLength != trailLength ||
        oldDelegate.bidirectionalTrail != bidirectionalTrail ||
        oldDelegate.showBasePath != showBasePath ||
        oldDelegate.pathBuilder != pathBuilder ||
        oldDelegate.firstLazerDirection != firstLazerDirection ||
        oldDelegate.secondLazerDirection != secondLazerDirection;
  }
}
