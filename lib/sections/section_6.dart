import 'package:flutter/material.dart';
import 'dart:ui' as ui show PathMetric, Tangent;

class Section6 extends StatefulWidget {
  const Section6({super.key});

  @override
  State<Section6> createState() => _Section6State();
}

class _Section6State extends State<Section6> {
  Path _buildCustomPath(Size size) {
    // Path coordinates: width ~14.25-15.15, height ~393.95-394.95
    final minWidth = 14.25;
    final maxWidth = 15.15;
    final minHeight = 393.95;
    final maxHeight = 394.95;
    final pathCenterX = (minWidth + maxWidth) / 2;
    final pathCenterY = (minHeight + maxHeight) / 2;
    final pathWidth = maxWidth - minWidth;

    // Calculate scale
    final scale = (size.width * 0.8) / pathWidth;

    // Create a transform matrix
    final matrix = Matrix4.identity()
      ..translate(size.width / 2, size.height / 2)
      ..scale(scale)
      ..translate(-pathCenterX, -pathCenterY);

    // Use raw coordinates
    double x(double w) => w;
    double y(double h) => h;

    Path path_0 = Path();
    path_0.moveTo(x(14.85000), y(394.4151));
    path_0.lineTo(x(14.85000), y(394.3151));
    path_0.cubicTo(
      x(14.85000),
      y(394.2875),
      x(14.82760),
      y(394.2500),
      x(14.80000),
      y(394.2500),
    );
    path_0.lineTo(x(14.60000), y(394.2500));
    path_0.cubicTo(
      x(14.57240),
      y(394.2500),
      x(14.55000),
      y(394.2875),
      x(14.55000),
      y(394.3151),
    );
    path_0.lineTo(x(14.55000), y(394.6151));
    path_0.cubicTo(
      x(14.55000),
      y(394.6427),
      x(14.57240),
      y(394.6500),
      x(14.60000),
      y(394.6500),
    );
    path_0.lineTo(x(15.00000), y(394.6500));
    path_0.cubicTo(
      x(15.02760),
      y(394.6500),
      x(15.05000),
      y(394.6427),
      x(15.05000),
      y(394.6151),
    );
    path_0.lineTo(x(15.05000), y(394.1151));
    path_0.cubicTo(
      x(15.05000),
      y(394.0875),
      x(15.02760),
      y(394.0500),
      x(15.00000),
      y(394.0500),
    );
    path_0.lineTo(x(14.40000), y(394.0500));
    path_0.cubicTo(
      x(14.37240),
      y(394.0500),
      x(14.35000),
      y(394.0875),
      x(14.35000),
      y(394.1151),
    );
    path_0.lineTo(x(14.35000), y(394.8151));
    path_0.cubicTo(
      x(14.35000),
      y(394.8427),
      x(14.37240),
      y(394.8500),
      x(14.40000),
      y(394.8500),
    );
    path_0.lineTo(x(15.10000), y(394.8500));
    path_0.cubicTo(
      x(15.12760),
      y(394.8500),
      x(15.15000),
      y(394.8762),
      x(15.15000),
      y(394.9038),
    );
    path_0.lineTo(x(15.15000), y(394.9076));
    path_0.cubicTo(
      x(15.15000),
      y(394.9352),
      x(15.12760),
      y(394.9500),
      x(15.10000),
      y(394.9500),
    );
    path_0.lineTo(x(14.35000), y(394.9500));
    path_0.cubicTo(
      x(14.29480),
      y(394.9500),
      x(14.25000),
      y(394.9203),
      x(14.25000),
      y(394.8651),
    );
    path_0.lineTo(x(14.25000), y(394.0651));
    path_0.cubicTo(
      x(14.25000),
      y(394.0099),
      x(14.29480),
      y(393.9500),
      x(14.35000),
      y(393.9500),
    );
    path_0.lineTo(x(15.05000), y(393.9500));
    path_0.cubicTo(
      x(15.10525),
      y(393.9500),
      x(15.15000),
      y(394.0099),
      x(15.15000),
      y(394.0651),
    );
    path_0.lineTo(x(15.15000), y(394.6651));
    path_0.cubicTo(
      x(15.15000),
      y(394.7203),
      x(15.10525),
      y(394.7500),
      x(15.05000),
      y(394.7500),
    );
    path_0.lineTo(x(14.55000), y(394.7500));
    path_0.cubicTo(
      x(14.49480),
      y(394.7500),
      x(14.45000),
      y(394.7203),
      x(14.45000),
      y(394.6651),
    );
    path_0.lineTo(x(14.45000), y(394.2651));
    path_0.cubicTo(
      x(14.45000),
      y(394.2099),
      x(14.49480),
      y(394.1500),
      x(14.55000),
      y(394.1500),
    );
    path_0.lineTo(x(14.85000), y(394.1500));
    path_0.cubicTo(
      x(14.90525),
      y(394.1500),
      x(14.95000),
      y(394.2099),
      x(14.95000),
      y(394.2651),
    );
    path_0.lineTo(x(14.95000), y(394.4651));
    path_0.cubicTo(
      x(14.95000),
      y(394.5204),
      x(14.90525),
      y(394.5500),
      x(14.85000),
      y(394.5500),
    );
    path_0.lineTo(x(14.75000), y(394.5500));
    path_0.cubicTo(
      x(14.69480),
      y(394.5500),
      x(14.65000),
      y(394.5204),
      x(14.65000),
      y(394.4651),
    );
    path_0.lineTo(x(14.65000), y(394.4151));
    path_0.cubicTo(
      x(14.65000),
      y(394.3875),
      x(14.67240),
      y(394.3651),
      x(14.70000),
      y(394.3651),
    );
    path_0.cubicTo(
      x(14.72760),
      y(394.3651),
      x(14.75000),
      y(394.3875),
      x(14.75000),
      y(394.4151),
    );
    path_0.cubicTo(
      x(14.75000),
      y(394.4427),
      x(14.77240),
      y(394.4651),
      x(14.80000),
      y(394.4651),
    );
    path_0.cubicTo(
      x(14.82760),
      y(394.4651),
      x(14.85000),
      y(394.4427),
      x(14.85000),
      y(394.4151),
    );

    // Apply transform
    return path_0.transform(matrix.storage);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final baseSize = Size(screenSize.width * 0.5, screenSize.height * 0.5);
    final widgetSize = Size(baseSize.width * 0.6, baseSize.height * 0.6);

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
            child: CustomLaserPathFollower(
              size: widgetSize,
              pathBuilder: _buildCustomPath,
              color: const Color(0xFF00E5FF),
              thickness: 3,
              duration: const Duration(seconds: 10),
              trailLength: 500,
              bidirectionalTrail: true,
              showBasePath: false,
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Laser Path Follower without container/box decoration
class CustomLaserPathFollower extends StatefulWidget {
  const CustomLaserPathFollower({
    super.key,
    required this.size,
    required this.pathBuilder,
    this.color = const Color(0xFF00E5FF),
    this.thickness = 3,
    this.duration = const Duration(seconds: 5),
    this.trailLength = 100,
    this.bidirectionalTrail = true,
    this.showBasePath = false,
  });

  final Size size;
  final Path Function(Size size) pathBuilder;
  final Color color;
  final double thickness;
  final Duration duration;
  final double trailLength;
  final bool bidirectionalTrail;
  final bool showBasePath;

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
            painter: _CustomLaserPainter(
              progress: _controller.value,
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
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness;
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
          ..color = color.withOpacity(0.35 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness * 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16)
          ..blendMode = BlendMode.plus;

        final Paint midGlow = Paint()
          ..color = color.withOpacity(0.6 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness * 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
          ..blendMode = BlendMode.plus;

        final Paint core = Paint()
          ..color = Colors.white.withOpacity(1.0 * fade)
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
        ..color = Colors.white
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

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Path coordinates: width ~14.25-15.15, height ~393.95-394.95
    // These are multipliers, so we need to normalize them
    // The path is very small (width range ~0.9, height range ~1.0)
    final minWidth = 14.25;
    final maxWidth = 15.15;
    final minHeight = 393.95;
    final maxHeight = 394.95;
    final pathCenterX = (minWidth + maxWidth) / 2;
    final pathCenterY = (minHeight + maxHeight) / 2;
    final pathWidth = maxWidth - minWidth;

    // Calculate scale - use the smaller dimension to ensure it fits
    final scale = (size.width * 0.8) / pathWidth;

    canvas.save();

    // Move to center of screen
    canvas.translate(size.width / 2, size.height / 2);

    // Scale the path
    canvas.scale(scale);

    // Translate to center the path (use raw coordinates, not multiplied by size)
    canvas.translate(-pathCenterX, -pathCenterY);

    // Use raw coordinates (these appear to be from a design tool in a normalized space)
    double x(double w) => w;
    double y(double h) => h;

    Path path_0 = Path();
    path_0.moveTo(x(14.85000), y(394.4151));
    path_0.lineTo(x(14.85000), y(394.3151));
    path_0.cubicTo(
      x(14.85000),
      y(394.2875),
      x(14.82760),
      y(394.2500),
      x(14.80000),
      y(394.2500),
    );
    path_0.lineTo(x(14.60000), y(394.2500));
    path_0.cubicTo(
      x(14.57240),
      y(394.2500),
      x(14.55000),
      y(394.2875),
      x(14.55000),
      y(394.3151),
    );
    path_0.lineTo(x(14.55000), y(394.6151));
    path_0.cubicTo(
      x(14.55000),
      y(394.6427),
      x(14.57240),
      y(394.6500),
      x(14.60000),
      y(394.6500),
    );
    path_0.lineTo(x(15.00000), y(394.6500));
    path_0.cubicTo(
      x(15.02760),
      y(394.6500),
      x(15.05000),
      y(394.6427),
      x(15.05000),
      y(394.6151),
    );
    path_0.lineTo(x(15.05000), y(394.1151));
    path_0.cubicTo(
      x(15.05000),
      y(394.0875),
      x(15.02760),
      y(394.0500),
      x(15.00000),
      y(394.0500),
    );
    path_0.lineTo(x(14.40000), y(394.0500));
    path_0.cubicTo(
      x(14.37240),
      y(394.0500),
      x(14.35000),
      y(394.0875),
      x(14.35000),
      y(394.1151),
    );
    path_0.lineTo(x(14.35000), y(394.8151));
    path_0.cubicTo(
      x(14.35000),
      y(394.8427),
      x(14.37240),
      y(394.8500),
      x(14.40000),
      y(394.8500),
    );
    path_0.lineTo(x(15.10000), y(394.8500));
    path_0.cubicTo(
      x(15.12760),
      y(394.8500),
      x(15.15000),
      y(394.8762),
      x(15.15000),
      y(394.9038),
    );
    path_0.lineTo(x(15.15000), y(394.9076));
    path_0.cubicTo(
      x(15.15000),
      y(394.9352),
      x(15.12760),
      y(394.9500),
      x(15.10000),
      y(394.9500),
    );
    path_0.lineTo(x(14.35000), y(394.9500));
    path_0.cubicTo(
      x(14.29480),
      y(394.9500),
      x(14.25000),
      y(394.9203),
      x(14.25000),
      y(394.8651),
    );
    path_0.lineTo(x(14.25000), y(394.0651));
    path_0.cubicTo(
      x(14.25000),
      y(394.0099),
      x(14.29480),
      y(393.9500),
      x(14.35000),
      y(393.9500),
    );
    path_0.lineTo(x(15.05000), y(393.9500));
    path_0.cubicTo(
      x(15.10525),
      y(393.9500),
      x(15.15000),
      y(394.0099),
      x(15.15000),
      y(394.0651),
    );
    path_0.lineTo(x(15.15000), y(394.6651));
    path_0.cubicTo(
      x(15.15000),
      y(394.7203),
      x(15.10525),
      y(394.7500),
      x(15.05000),
      y(394.7500),
    );
    path_0.lineTo(x(14.55000), y(394.7500));
    path_0.cubicTo(
      x(14.49480),
      y(394.7500),
      x(14.45000),
      y(394.7203),
      x(14.45000),
      y(394.6651),
    );
    path_0.lineTo(x(14.45000), y(394.2651));
    path_0.cubicTo(
      x(14.45000),
      y(394.2099),
      x(14.49480),
      y(394.1500),
      x(14.55000),
      y(394.1500),
    );
    path_0.lineTo(x(14.85000), y(394.1500));
    path_0.cubicTo(
      x(14.90525),
      y(394.1500),
      x(14.95000),
      y(394.2099),
      x(14.95000),
      y(394.2651),
    );
    path_0.lineTo(x(14.95000), y(394.4651));
    path_0.cubicTo(
      x(14.95000),
      y(394.5204),
      x(14.90525),
      y(394.5500),
      x(14.85000),
      y(394.5500),
    );
    path_0.lineTo(x(14.75000), y(394.5500));
    path_0.cubicTo(
      x(14.69480),
      y(394.5500),
      x(14.65000),
      y(394.5204),
      x(14.65000),
      y(394.4651),
    );
    path_0.lineTo(x(14.65000), y(394.4151));
    path_0.cubicTo(
      x(14.65000),
      y(394.3875),
      x(14.67240),
      y(394.3651),
      x(14.70000),
      y(394.3651),
    );
    path_0.cubicTo(
      x(14.72760),
      y(394.3651),
      x(14.75000),
      y(394.3875),
      x(14.75000),
      y(394.4151),
    );
    path_0.cubicTo(
      x(14.75000),
      y(394.4427),
      x(14.77240),
      y(394.4651),
      x(14.80000),
      y(394.4651),
    );
    path_0.cubicTo(
      x(14.82760),
      y(394.4651),
      x(14.85000),
      y(394.4427),
      x(14.85000),
      y(394.4151),
    );

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = const Color.fromARGB(255, 0, 0, 0);
    canvas.drawPath(path_0, paint_0_fill);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
