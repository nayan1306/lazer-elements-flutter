import 'package:flutter/material.dart';
import 'dart:ui' as ui show PathMetric, Tangent;

class ShootingStarPathFollower extends StatefulWidget {
  const ShootingStarPathFollower({
    super.key,
    this.color = const Color(0xFF00E5FF),
    this.headColor,
    this.thickness = 3,
    this.duration = const Duration(seconds: 9),
    this.trailLength = 80,
    this.backgroundColor = Colors.black,
    this.showBasePath = true,
    this.size = const Size(500, 500),
    this.pathBuilder,
  });

  final Color color;
  final Color? headColor; // Optional head color, defaults to white if not specified
  final double thickness;
  final Duration duration;
  final double trailLength; // in logical pixels along the path
  final Color backgroundColor;
  final bool showBasePath;
  final Size size;
  final Path Function(Size size)? pathBuilder;

  @override
  State<ShootingStarPathFollower> createState() =>
      _ShootingStarPathFollowerState();
}

class _ShootingStarPathFollowerState extends State<ShootingStarPathFollower>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
          _controller.forward();
        }
      })
      ..forward();
  }

  @override
  void didUpdateWidget(covariant ShootingStarPathFollower oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller
        ..duration = widget.duration
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.size.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
      ),
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _LaserPainter(
                progress: _controller.value,
                color: widget.color,
                headColor: widget.headColor,
                thickness: widget.thickness,
                trailLength: widget.trailLength,
                showBasePath: widget.showBasePath,
                pathBuilder: widget.pathBuilder,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LaserPainter extends CustomPainter {
  _LaserPainter({
    required this.progress,
    required this.color,
    this.headColor,
    required this.thickness,
    required this.trailLength,
    required this.showBasePath,
    required this.pathBuilder,
  });

  final double progress; // 0..1
  final Color color;
  final Color? headColor;
  final double thickness;
  final double trailLength;
  final bool showBasePath;
  final Path Function(Size size)? pathBuilder;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = (pathBuilder?.call(size)) ?? _defaultPath(size);
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
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness;
      canvas.drawPath(path, basePaint);
    }

    // isolate additive blending to avoid platform artifacts
    canvas.saveLayer(Offset.zero & size, Paint());

    void drawSegment(double a, double b) {
      const double eps = 0.001; // avoid degenerate subpaths
      final double aa = a.clamp(0.0, length);
      final double bb = b.clamp(0.0, length);
      if (bb <= aa + eps) return;

      // Slice the segment into small pieces with a fade, which smooths corners/joins
      const int slices = 10;
      final double segLen = bb - aa;
      final double step = segLen / slices;

      for (int k = 0; k < slices; k++) {
        final double sa = aa + step * k;
        final double sb = k == slices - 1 ? bb : (aa + step * (k + 1));
        if (sb <= sa + eps) continue;

        // tail closer to head is brighter
        final double t = (k + 1) / slices; // 0..1
        final double fade = t * t; // quadratic falloff

        final Path sub = metric.extractPath(sa, sb);

        final Paint outerGlow = Paint()
          ..color = color.withOpacity(0.6 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness * 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24)
          ..blendMode = BlendMode.plus;

        final Paint midGlow = Paint()
          ..color = color.withOpacity(0.8 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness * 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
          ..blendMode = BlendMode.plus;

        final Paint core = Paint()
          ..color =
              headColor?.withOpacity(1.0 * fade) ??
              Colors.white.withOpacity(1.0 * fade)
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

    if (start >= 0) {
      drawSegment(start, end);
    } else {
      drawSegment(length + start, length);
      drawSegment(0, end);
    }

    // Draw a bright traveling head dot
    final ui.Tangent? t = metric.getTangentForOffset(end.clamp(0.0, length));
    if (t != null) {
      final effectiveHeadColor = headColor ?? Colors.white;
      final Paint headOuter = Paint()
        ..color = color.withOpacity(0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
        ..blendMode = BlendMode.plus;
      final Paint headCore = Paint()
        ..color = effectiveHeadColor
        ..blendMode = BlendMode.plus;

      canvas.drawCircle(t.position, thickness * 2.0, headOuter);
      canvas.drawCircle(t.position, thickness * 0.7, headCore);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LaserPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.headColor != headColor ||
        oldDelegate.thickness != thickness ||
        oldDelegate.trailLength != trailLength ||
        oldDelegate.showBasePath != showBasePath ||
        oldDelegate.pathBuilder != pathBuilder;
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
}
