import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'dart:ui' as ui show PathMetric, Tangent;

/// A dual laser path follower widget that animates two lazers following a triangle path.
class TriangleLazerFollower extends StatefulWidget {
  const TriangleLazerFollower({
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
    this.reverseFirstLazer = false,
    this.reverseSecondLazer = false,
    required this.pathBuilder,
    this.firstPathBuilder,
    this.secondPathBuilder,
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
  final bool reverseFirstLazer;
  final bool reverseSecondLazer;
  final Path Function(Size size) pathBuilder;
  final Path Function(Size size)? firstPathBuilder;
  final Path Function(Size size)? secondPathBuilder;

  @override
  State<TriangleLazerFollower> createState() => _TriangleLazerFollowerState();
}

class _TriangleLazerFollowerState extends State<TriangleLazerFollower>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant TriangleLazerFollower oldWidget) {
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
                  painter: _DualTriangleLaserPainter(
                    progress: _controller.value,
                    color: widget.color,
                    coreColor: widget.coreColor,
                    glowColors: widget.glowColors,
                    coreColors: widget.coreColors,
                    thickness: widget.thickness,
                    trailLength: widget.trailLength,
                    bidirectionalTrail: widget.bidirectionalTrail,
                    showBasePath: widget.showBasePath,
                    reverseFirstLazer: widget.reverseFirstLazer,
                    reverseSecondLazer: widget.reverseSecondLazer,
                    pathBuilder: widget.pathBuilder,
                    firstPathBuilder: widget.firstPathBuilder,
                    secondPathBuilder: widget.secondPathBuilder,
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

class _DualTriangleLaserPainter extends CustomPainter {
  _DualTriangleLaserPainter({
    required this.progress,
    required this.color,
    required this.coreColor,
    required this.glowColors,
    required this.coreColors,
    required this.thickness,
    required this.trailLength,
    required this.bidirectionalTrail,
    required this.showBasePath,
    required this.reverseFirstLazer,
    required this.reverseSecondLazer,
    required this.pathBuilder,
    this.firstPathBuilder,
    this.secondPathBuilder,
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
  final bool reverseFirstLazer;
  final bool reverseSecondLazer;
  final Path Function(Size size) pathBuilder;
  final Path Function(Size size)? firstPathBuilder;
  final Path Function(Size size)? secondPathBuilder;

  // Helper to normalize progress value (handle negative modulo)
  static double normalizeProgress(double p) {
    if (!p.isFinite) return 0.0;
    double r = p % 1.0;
    if (r < 0) r += 1.0;
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
    if (!length.isFinite || length <= 0) return;
    if (!normalizedProgress.isFinite) return;

    final double clampedTrail = trailLength.clamp(0.0, length * 0.99);
    // When progress is very small (< 0.01), force end to be 0 to ensure we start exactly at the top
    double rawProgress = normalizedProgress.clamp(0.0, 1.0);
    if (rawProgress < 0.01 && !reverse) {
      rawProgress = 0.0;
    }
    final double end = rawProgress * length;

    if (!end.isFinite) return;

    final double back = clampedTrail;
    final double front = bidirectionalTrail ? clampedTrail : 0.0;
    final double totalSpan = back + front;
    const double eps = 0.0001;

    double stepLen = 0.0;
    if (totalSpan > 0) {
      final int slices = (totalSpan / math.max(2.0, thickness * 1.6))
          .clamp(70, 150)
          .round();
      stepLen = totalSpan / slices;
      final double overlap = stepLen * 0.35;

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
        if (!r.isFinite) return 0.0;
        return r.clamp(0.0, length);
      }

      void drawSub(double a, double b, double fade, double tAlong) {
        if (!a.isFinite || !b.isFinite) return;
        if (!length.isFinite || length <= 0) return;
        if (b <= a + eps) return;

        final double safeA = a.clamp(0.0, length);
        final double safeB = b.clamp(0.0, length);
        if (safeB <= safeA + eps) return;
        if (!safeA.isFinite || !safeB.isFinite) return;

        final Path sub = metric.extractPath(safeA, safeB);

        final Color glowBase = glowColors != null
            ? _sample(glowColors!, tAlong)
            : color;
        final Color coreBase = coreColors != null
            ? _sample(coreColors!, tAlong)
            : coreColor;

        final double outerStrokeWidth = (thickness * 3).clamp(0.5, 1000.0);
        final double midStrokeWidth = (thickness * 2).clamp(0.5, 1000.0);
        final double coreStrokeWidth = thickness.clamp(0.5, 1000.0);

        if (!outerStrokeWidth.isFinite ||
            !midStrokeWidth.isFinite ||
            !coreStrokeWidth.isFinite)
          return;

        final Paint outerGlow = Paint()
          ..color = glowBase.withOpacity((0.35 * fade).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = outerStrokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16)
          ..blendMode = BlendMode.plus;

        final Paint midGlow = Paint()
          ..color = glowBase.withOpacity((0.6 * fade).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = midStrokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
          ..blendMode = BlendMode.plus;

        final Paint core = Paint()
          ..color = coreBase.withOpacity((1.0 * fade).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = coreStrokeWidth
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
        final double localStart = reverse
            ? (back - (i + 1) * stepLen)
            : (-back + i * stepLen);
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

        double sa, sb;
        if (reverse) {
          sa = wrap(end + localEnd - overlap);
          sb = wrap(end + localStart + overlap);
        } else {
          // When not reversed, ensure we don't go before position 0
          // This ensures the lazer starts exactly at the top tip (position 0)
          final double rawSa = end + localStart - overlap;
          final double rawSb = end + localEnd + overlap;

          if (rawSb <= 0) {
            // This segment is entirely before position 0, skip it
            sa = 0;
            sb = 0;
          } else {
            // If rawSa is negative, start from 0 (the top tip)
            sa = rawSa < 0 ? 0.0 : rawSa.clamp(0.0, length);
            sb = rawSb.clamp(0.0, length);
          }
        }

        if (!sa.isFinite || !sb.isFinite) continue;

        final double tAlong = totalSpan <= 0
            ? 0.5
            : ((localCenter + back) / totalSpan).clamp(0.0, 1.0);

        if (sb > sa) {
          drawSub(sa, sb, fade, tAlong);
        } else if (sa > sb && sa < length) {
          // Wrap-around case (only if sa is not at the end)
          drawSub(sa, length, fade, tAlong);
          drawSub(0, sb, fade, tAlong);
        }
      }

      // ALWAYS ensure we draw from position 0 (top tip) when near the start
      // This guarantees visibility at the very beginning of the animation
      if (!reverse && stepLen > 0 && length > 0) {
        // When end is very close to 0, draw a prominent segment from 0
        if (end <= 0.02) {
          // Draw a longer, fully opaque segment starting exactly from 0
          // Make it more visible by ensuring it's at least 5% of path length
          final double minSegmentLength = math.max(stepLen * 5, length * 0.05);
          final double firstSegmentEnd = math.min(
            minSegmentLength,
            length * 0.2,
          );
          if (firstSegmentEnd > eps && firstSegmentEnd.isFinite) {
            drawSub(0.0, firstSegmentEnd, 1.0, 0.0);
          }
        }
        // Also ensure position 0 is always included in early progress
        else if (end <= stepLen * 4 && end > 0) {
          // Draw a segment from 0 to cover the start, fading as we move forward
          final double startSegmentEnd = math.min(end + stepLen * 3, length);
          if (startSegmentEnd > eps && startSegmentEnd.isFinite) {
            final double fade = 1.0 - (end / (stepLen * 4)).clamp(0.0, 0.7);
            if (fade > 0.15) {
              drawSub(0.0, startSegmentEnd, fade, 0.0);
            }
          }
        }
      }
    }

    // Head dot - ALWAYS draw at position 0 when end is very close to 0
    // This ensures visibility at the start
    double headPosition = end.clamp(0.0, length);
    if (headPosition < 0.02 && !reverse) {
      headPosition = 0.0; // Force to exactly 0 when very close
    }

    if (!headPosition.isFinite || !length.isFinite || length <= 0) return;
    if (headPosition < 0 || headPosition > length) return;

    final ui.Tangent? t = metric.getTangentForOffset(headPosition);
    if (t != null &&
        t.position.dx.isFinite &&
        t.position.dy.isFinite &&
        thickness > 0 &&
        thickness.isFinite) {
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

      final double outerRadius = (thickness * 1.6).clamp(0.5, 100.0);
      final double coreRadius = (thickness * 0.7).clamp(0.5, 100.0);
      if (outerRadius.isFinite && coreRadius.isFinite) {
        canvas.drawCircle(t.position, outerRadius, headOuter);
        canvas.drawCircle(t.position, coreRadius, headCore);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0)
      return;

    // Use separate path builders if provided, otherwise use the main path builder
    final Path? firstPath = firstPathBuilder?.call(size);
    final Path? secondPath = secondPathBuilder?.call(size);
    final Path basePath = pathBuilder(size);

    if (showBasePath) {
      final Paint basePaint = Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness;
      canvas.drawPath(basePath, basePaint);
    }

    canvas.saveLayer(Offset.zero & size, Paint());

    // First lazer
    if (firstPath != null) {
      final List<ui.PathMetric> firstMetrics = firstPath
          .computeMetrics()
          .toList();
      if (firstMetrics.isNotEmpty) {
        final ui.PathMetric firstMetric = firstMetrics.first;
        final double firstLength = firstMetric.length;
        if (firstLength.isFinite && firstLength > 0) {
          double firstProgress = reverseFirstLazer
              ? normalizeProgress(1.0 - progress)
              : normalizeProgress(progress);
          _drawLaser(
            canvas,
            firstMetric,
            firstLength,
            firstProgress,
            reverse: reverseFirstLazer,
          );
        }
      }
    }

    // Second lazer
    if (secondPath != null) {
      final List<ui.PathMetric> secondMetrics = secondPath
          .computeMetrics()
          .toList();
      if (secondMetrics.isNotEmpty) {
        final ui.PathMetric secondMetric = secondMetrics.first;
        final double secondLength = secondMetric.length;
        if (secondLength.isFinite && secondLength > 0) {
          double secondProgress = reverseSecondLazer
              ? normalizeProgress(1.0 - progress)
              : normalizeProgress(progress);
          _drawLaser(
            canvas,
            secondMetric,
            secondLength,
            secondProgress,
            reverse: reverseSecondLazer,
          );
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DualTriangleLaserPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.trailLength != trailLength ||
        oldDelegate.bidirectionalTrail != bidirectionalTrail ||
        oldDelegate.showBasePath != showBasePath ||
        oldDelegate.pathBuilder != pathBuilder ||
        oldDelegate.firstPathBuilder != firstPathBuilder ||
        oldDelegate.secondPathBuilder != secondPathBuilder ||
        oldDelegate.reverseFirstLazer != reverseFirstLazer ||
        oldDelegate.reverseSecondLazer != reverseSecondLazer;
  }
}
