import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui show PathMetric, Tangent;

/// A responsive laser path follower widget.
///
/// Provide either [pathBuilder] (preferred, size-aware) or a raw [path] with
/// [pathFit]/[pathAlignment]/[padding] to automatically fit it to the widget's
/// layout size.
class LazerPathFollowerWidget extends StatefulWidget {
  const LazerPathFollowerWidget({
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
    this.pathBuilder,
    this.path,
    this.pathFit = BoxFit.contain,
    this.pathAlignment = Alignment.center,
    this.padding = EdgeInsets.zero,
  });

  final Color color;
  final Color coreColor; // line/core stroke color
  final List<Color>? glowColors; // optional gradient for glow
  final List<Color>? coreColors; // optional gradient for core
  final double thickness;
  final Duration duration;
  final double trailLength;
  final bool bidirectionalTrail;
  final bool showBasePath;
  final Color? backgroundColor;

  // Path sources
  final Path Function(Size size)? pathBuilder; // size-aware builder
  final Path? path; // raw path to be fitted
  final BoxFit pathFit;
  final Alignment pathAlignment;
  final EdgeInsets padding;

  @override
  State<LazerPathFollowerWidget> createState() =>
      _LazerPathFollowerWidgetState();
}

class _LazerPathFollowerWidgetState extends State<LazerPathFollowerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant LazerPathFollowerWidget oldWidget) {
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

        Path Function(Size size) effectiveBuilder;
        if (widget.pathBuilder != null) {
          effectiveBuilder = widget.pathBuilder!;
        } else if (widget.path != null) {
          effectiveBuilder = (Size s) => _fitPathToSize(
            widget.path!,
            s,
            widget.padding,
            widget.pathFit,
            widget.pathAlignment,
          );
        } else {
          effectiveBuilder = _defaultPath;
        }

        return SizedBox(
          width: size.width,
          height: size.height,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LaserPainter(
                    progress: _controller.value,
                    color: widget.color,
                    coreColor: widget.coreColor,
                    glowColors: widget.glowColors,
                    coreColors: widget.coreColors,
                    thickness: widget.thickness,
                    trailLength: widget.trailLength,
                    bidirectionalTrail: widget.bidirectionalTrail,
                    showBasePath: widget.showBasePath,
                    pathBuilder: effectiveBuilder,
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

Path _fitPathToSize(
  Path source,
  Size targetSize,
  EdgeInsets padding,
  BoxFit fit,
  Alignment alignment,
) {
  final Rect bounds = source.getBounds();
  final Rect content = padding.deflateRect(Offset.zero & targetSize);
  final double scaleX = content.width / (bounds.width == 0 ? 1 : bounds.width);
  final double scaleY =
      content.height / (bounds.height == 0 ? 1 : bounds.height);

  double sx, sy;
  switch (fit) {
    case BoxFit.fill:
      sx = scaleX;
      sy = scaleY;
      break;
    case BoxFit.contain:
      sx = sy = math.min(scaleX, scaleY);
      break;
    case BoxFit.cover:
      sx = sy = math.max(scaleX, scaleY);
      break;
    case BoxFit.fitWidth:
      sx = sy = scaleX;
      break;
    case BoxFit.fitHeight:
      sx = sy = scaleY;
      break;
    case BoxFit.none:
      sx = sy = 1.0;
      break;
    case BoxFit.scaleDown:
      final double m = math.min(1.0, math.min(scaleX, scaleY));
      sx = sy = m;
      break;
  }

  final double w = bounds.width * sx;
  final double h = bounds.height * sy;
  final double freeX = content.width - w;
  final double freeY = content.height - h;
  final double ax = (alignment.x + 1) / 2.0; // 0..1
  final double ay = (alignment.y + 1) / 2.0; // 0..1
  final double dx = content.left + freeX * ax - bounds.left * sx;
  final double dy = content.top + freeY * ay - bounds.top * sy;

  final Float64List m4 = Float64List(16)
    ..[0] = sx
    ..[5] = sy
    ..[10] = 1
    ..[12] = dx
    ..[13] = dy
    ..[15] = 1;

  return source.transform(m4);
}

Path _defaultPath(Size size) {
  final double w = size.width;
  final double h = size.height;
  const double pad = 24;
  final Path p = Path();

  p.moveTo(pad, h * 0.2);
  p.cubicTo(w * 0.35, h * 0.05, w * 0.65, h * 0.35, w - pad, h * 0.22);
  p.quadraticBezierTo(w * 0.55, h * 0.55, pad, h * 0.8);
  p.cubicTo(w * 0.25, h * 0.62, w * 0.75, h * 0.62, w - pad, h * 0.78);

  return p;
}

class _LaserPainter extends CustomPainter {
  _LaserPainter({
    required this.progress,
    required this.color,
    required this.coreColor,
    required this.glowColors,
    required this.coreColors,
    required this.thickness,
    required this.trailLength,
    required this.bidirectionalTrail,
    required this.showBasePath,
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

    if (showBasePath) {
      final Paint basePaint = Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness;
      canvas.drawPath(path, basePaint);
    }

    canvas.saveLayer(Offset.zero & size, Paint());

    double wrap(double o) {
      double r = o % length;
      if (r < 0) r += length;
      return r;
    }

    final double back = clampedTrail;
    final double front = bidirectionalTrail ? clampedTrail : 0.0;
    final double totalSpan = back + front;
    if (totalSpan > 0) {
      final int slices = (totalSpan / math.max(2.0, thickness * 1.6))
          .clamp(70, 150)
          .round();
      final double stepLen = totalSpan / slices;
      final double overlap = stepLen * 0.35; // overlap to avoid slice seams
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

      void drawSub(double a, double b, double fade, double tAlong) {
        if (b <= a + eps) return;
        final Path sub = metric.extractPath(a, b);

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
          ..strokeCap = StrokeCap
              .butt // avoid dotty caps at slice edges
          ..strokeJoin = StrokeJoin.round
          ..blendMode = BlendMode.plus;

        canvas.drawPath(sub, outerGlow);
        canvas.drawPath(sub, midGlow);
        if (fade > 0.12) {
          // skip near-zero cores to avoid speckles
          canvas.drawPath(sub, core);
        }
      }

      for (int i = 0; i < slices; i++) {
        final double localStart = -back + i * stepLen;
        final double localEnd = localStart + stepLen;
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

        final double sa = wrap(end + localStart - overlap);
        final double sb = wrap(end + localEnd + overlap);

        // map this slice center position to 0..1 along the entire span
        // 0 => far back tail, 1 => far front tail
        final double tAlong = totalSpan <= 0
            ? 0.5
            : ((localCenter + back) / totalSpan).clamp(0.0, 1.0);

        if (sb > sa) {
          drawSub(sa, sb, fade, tAlong);
        } else {
          // Seam crossing: split the slice to two parts
          drawSub(sa, length, fade, tAlong);
          drawSub(0, sb, fade, tAlong);
        }
      }
    }

    // Head dot
    final ui.Tangent? t = metric.getTangentForOffset(end.clamp(0.0, length));
    if (t != null) {
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

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LaserPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.trailLength != trailLength ||
        oldDelegate.bidirectionalTrail != bidirectionalTrail ||
        oldDelegate.showBasePath != showBasePath ||
        oldDelegate.pathBuilder != pathBuilder;
  }
}
