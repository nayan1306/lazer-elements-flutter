import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Section5 extends StatefulWidget {
  const Section5({super.key});

  @override
  State<Section5> createState() => _Section5State();
}

class _Section5State extends State<Section5> with TickerProviderStateMixin {
  late AnimationController _rightRotationController;
  late AnimationController _leftRotationController;

  @override
  void initState() {
    super.initState();
    _rightRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _leftRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _rightRotationController.dispose();
    _leftRotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A), // Very dark charcoal background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF0F0F0F), Color(0xFF0A0A0A)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Engrossed flower pattern on the right side
            Positioned(
              right: -200,
              top: 0,
              bottom: -660,
              width: size.width * 0.4,
              child: Center(
                child: AnimatedBuilder(
                  animation: _rightRotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rightRotationController.value * 2 * math.pi,
                      child: SizedBox(
                        width: size.width * 0.4,
                        height: size.width * 0.4,
                        child: const EngrossedFlowerPattern(),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: -200,
              top: -200,
              width: size.width * 0.4,
              child: Center(
                child: AnimatedBuilder(
                  animation: _leftRotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _leftRotationController.value * 2 * math.pi,
                      child: SizedBox(
                        width: size.width * 0.4,
                        height: size.width * 0.4,
                        child: const EngrossedFlowerPattern(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EngrossedFlowerPattern extends StatelessWidget {
  const EngrossedFlowerPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return CustomPaint(painter: EngrossedFlowerPainter(), size: size);
      },
    );
  }
}

class EngrossedFlowerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Colors for embossed effect
    const shapeColor = ui.Color.fromARGB(
      255,
      36,
      36,
      36,
    ); // Slightly lighter gray for shapes
    const highlightColor = ui.Color.fromARGB(
      255,
      58,
      58,
      58,
    ); // Light highlight
    const shadowColor = ui.Color.fromARGB(255, 22, 22, 22); // Dark shadow

    // Helper function to create embossed/debossed effect (neumorphic)
    void drawEmbossedShape(Path path) {
      final bounds = path.getBounds();

      // Create gradient for embossed lighting effect
      final gradient = ui.Gradient.radial(
        Offset(
          bounds.left + bounds.width * 0.3,
          bounds.top + bounds.height * 0.3,
        ),
        bounds.width * 0.8,
        [
          highlightColor.withOpacity(0.5),
          shapeColor,
          shadowColor.withOpacity(0.6),
        ],
        [0.0, 0.5, 1.0],
      );

      // Draw outer shadow for depth
      canvas.drawPath(
        path,
        Paint()
          ..color = shadowColor.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
          ..style = PaintingStyle.fill,
      );

      // Draw main shape with gradient fill
      canvas.drawPath(
        path,
        Paint()
          ..shader = gradient
          ..style = PaintingStyle.fill,
      );

      // Draw subtle inner shadow for debossed effect
      canvas.drawPath(
        path,
        Paint()
          ..color = shadowColor.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
          ..style = PaintingStyle.fill,
      );

      // Redraw main shape to maintain shape integrity
      canvas.drawPath(
        path,
        Paint()
          ..shader = gradient
          ..style = PaintingStyle.fill,
      );

      // Add subtle highlight edge
      canvas.drawPath(
        path,
        Paint()
          ..color = highlightColor.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    // Flower pattern paths
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.1724088, size.height * 0.4550984);
    path_0.cubicTo(
      size.width * 0.1801530,
      size.height * 0.4508481,
      size.width * 0.1881310,
      size.height * 0.4469082,
      size.width * 0.1964655,
      size.height * 0.4434297,
    );
    path_0.cubicTo(
      size.width * 0.2294841,
      size.height * 0.4296752,
      size.width * 0.2665716,
      size.height * 0.4226854,
      size.width * 0.3066501,
      size.height * 0.4226854,
    );
    path_0.cubicTo(
      size.width * 0.3288855,
      size.height * 0.4226854,
      size.width * 0.3505000,
      size.height * 0.4249024,
      size.width * 0.3709820,
      size.height * 0.4283153,
    );
    path_0.lineTo(size.width * 0.2484400, size.height * 0.3452768);
    path_0.lineTo(size.width * 0.4487382, size.height * 0.4479096);
    path_0.cubicTo(
      size.width * 0.4629978,
      size.height * 0.4527502,
      size.width * 0.4753705,
      size.height * 0.4575778,
      size.width * 0.4853491,
      size.height * 0.4617778,
    );
    path_0.cubicTo(
      size.width * 0.4853841,
      size.height * 0.4616816,
      size.width * 0.4854322,
      size.height * 0.4615482,
      size.width * 0.4854803,
      size.height * 0.4614148,
    );
    path_0.cubicTo(
      size.width * 0.4723686,
      size.height * 0.4090971,
      size.width * 0.4345924,
      size.height * 0.2961249,
      size.width * 0.3440830,
      size.height * 0.2425237,
    );
    path_0.cubicTo(
      size.width * 0.2996734,
      size.height * 0.2162347,
      size.width * 0.2487986,
      size.height * 0.2079615,
      size.width * 0.2023403,
      size.height * 0.2079615,
    );
    path_0.cubicTo(
      size.width * 0.1232722,
      size.height * 0.2079615,
      size.width * 0.05697038,
      size.height * 0.2319220,
      size.width * 0.05697038,
      size.height * 0.2319220,
    );
    path_0.cubicTo(
      size.width * 0.05697038,
      size.height * 0.2319220,
      size.width * 0.07958844,
      size.height * 0.3750443,
      size.width * 0.1724088,
      size.height * 0.4550984,
    );
    path_0.close();

    drawEmbossedShape(path_0);

    Path path_1 = Path();
    path_1.moveTo(size.width * 0.2352146, size.height * 0.6144502);
    path_1.lineTo(size.width * 0.3679976, size.height * 0.5493509);
    path_1.cubicTo(
      size.width * 0.3984079,
      size.height * 0.5195965,
      size.width * 0.4285055,
      size.height * 0.4978661,
      size.width * 0.4477741,
      size.height * 0.4853469,
    );
    path_1.cubicTo(
      size.width * 0.4122761,
      size.height * 0.4724779,
      size.width * 0.3609575,
      size.height * 0.4583014,
      size.width * 0.3066348,
      size.height * 0.4583014,
    );
    path_1.cubicTo(
      size.width * 0.2745847,
      size.height * 0.4583014,
      size.width * 0.2414983,
      size.height * 0.4632252,
      size.width * 0.2101544,
      size.height * 0.4763019,
    );
    path_1.cubicTo(
      size.width * 0.08144030,
      size.height * 0.5299184,
      size.width * 0.02982872,
      size.height * 0.6999878,
      size.width * 0.02982872,
      size.height * 0.6999878,
    );
    path_1.cubicTo(
      size.width * 0.02982872,
      size.height * 0.6999878,
      size.width * 0.1196625,
      size.height * 0.7475305,
      size.width * 0.2191142,
      size.height * 0.7475305,
    );
    path_1.cubicTo(
      size.width * 0.2344603,
      size.height * 0.7475305,
      size.width * 0.2500470,
      size.height * 0.7463149,
      size.width * 0.2655593,
      size.height * 0.7436912,
    );
    path_1.cubicTo(
      size.width * 0.2663115,
      size.height * 0.7357306,
      size.width * 0.2671991,
      size.height * 0.7277569,
      size.width * 0.2687252,
      size.height * 0.7197307,
    );
    path_1.cubicTo(
      size.width * 0.2793750,
      size.height * 0.6636524,
      size.width * 0.3085041,
      size.height * 0.6158779,
      size.width * 0.3413304,
      size.height * 0.5776579,
    );
    path_1.lineTo(size.width * 0.2352146, size.height * 0.6144502);
    path_1.close();

    drawEmbossedShape(path_1);

    Path path_2 = Path();
    path_2.moveTo(size.width * 0.4328367, size.height * 0.7814171);
    path_2.lineTo(size.width * 0.4667081, size.height * 0.5155408);
    path_2.cubicTo(
      size.width * 0.4245810,
      size.height * 0.5430607,
      size.width * 0.3241629,
      size.height * 0.6186699,
      size.width * 0.3036963,
      size.height * 0.7263751,
    );
    path_2.cubicTo(
      size.width * 0.2776697,
      size.height * 0.8633581,
      size.width * 0.3913350,
      size.height * 1.000000,
      size.width * 0.3913350,
      size.height * 1.000000,
    );
    path_2.cubicTo(
      size.width * 0.3913350,
      size.height * 1.000000,
      size.width * 0.5424332,
      size.height * 0.9168740,
      size.width * 0.5717087,
      size.height * 0.7833696,
    );
    path_2.cubicTo(
      size.width * 0.5144301,
      size.height * 0.7221598,
      size.width * 0.4924570,
      size.height * 0.6393967,
      size.width * 0.4843324,
      size.height * 0.5786570,
    );
    path_2.lineTo(size.width * 0.4328367, size.height * 0.7814171);
    path_2.close();

    drawEmbossedShape(path_2);

    Path path_3 = Path();
    path_3.moveTo(size.width * 0.7943911, size.height * 0.5685647);
    path_3.cubicTo(
      size.width * 0.7897625,
      size.height * 0.5643800,
      size.width * 0.7847120,
      size.height * 0.5609671,
      size.width * 0.7798167,
      size.height * 0.5572240,
    );
    path_3.cubicTo(
      size.width * 0.7521984,
      size.height * 0.5655628,
      size.width * 0.7223303,
      size.height * 0.5700252,
      size.width * 0.6902956,
      size.height * 0.5700252,
    );
    path_3.cubicTo(
      size.width * 0.6566188,
      size.height * 0.5700252,
      size.width * 0.6247152,
      size.height * 0.5652152,
      size.width * 0.5965044,
      size.height * 0.5589797,
    );
    path_3.lineTo(size.width * 0.7243505, size.height * 0.6902037);
    path_3.lineTo(size.width * 0.5423151, size.height * 0.5440620);
    path_3.cubicTo(
      size.width * 0.5320785,
      size.height * 0.5406338,
      size.width * 0.5229023,
      size.height * 0.5373499,
      size.width * 0.5158928,
      size.height * 0.5345578,
    );
    path_3.cubicTo(
      size.width * 0.5189777,
      size.height * 0.5907346,
      size.width * 0.5347481,
      size.height * 0.7032323,
      size.width * 0.6099310,
      size.height * 0.7715544,
    );
    path_3.cubicTo(
      size.width * 0.6767706,
      size.height * 0.8322744,
      size.width * 0.7740884,
      size.height * 0.8429767,
      size.width * 0.8343864,
      size.height * 0.8429767,
    );
    path_3.cubicTo(
      size.width * 0.8671930,
      size.height * 0.8429767,
      size.width * 0.8890349,
      size.height * 0.8398065,
      size.width * 0.8890349,
      size.height * 0.8398065,
    );
    path_3.cubicTo(
      size.width * 0.8890349,
      size.height * 0.8398065,
      size.width * 0.8975705,
      size.height * 0.6623056,
      size.width * 0.7943911,
      size.height * 0.5685647,
    );
    path_3.close();

    drawEmbossedShape(path_3);

    Path path_4 = Path();
    path_4.moveTo(size.width * 0.7684935, size.height * 0.3752083);
    path_4.lineTo(size.width * 0.5607944, size.height * 0.4878219);
    path_4.cubicTo(
      size.width * 0.5515897,
      size.height * 0.4949451,
      size.width * 0.5436291,
      size.height * 0.5005225,
      size.width * 0.5374264,
      size.height * 0.5046264,
    );
    path_4.cubicTo(
      size.width * 0.5690195,
      size.height * 0.5164896,
      size.width * 0.6269672,
      size.height * 0.5344289,
      size.width * 0.6902977,
      size.height * 0.5344289,
    );
    path_4.cubicTo(
      size.width * 0.7264516,
      size.height * 0.5344289,
      size.width * 0.7641448,
      size.height * 0.5285191,
      size.width * 0.7992011,
      size.height * 0.5121912,
    );
    path_4.cubicTo(
      size.width * 0.9255998,
      size.height * 0.4533406,
      size.width * 0.9701713,
      size.height * 0.2812706,
      size.width * 0.9701713,
      size.height * 0.2812706,
    );
    path_4.cubicTo(
      size.width * 0.9701713,
      size.height * 0.2812706,
      size.width * 0.8864921,
      size.height * 0.2413103,
      size.width * 0.7923905,
      size.height * 0.2413103,
    );
    path_4.cubicTo(
      size.width * 0.7569253,
      size.height * 0.2413277,
      size.width * 0.7200303,
      size.height * 0.2471369,
      size.width * 0.6855358,
      size.height * 0.2627433,
    );
    path_4.cubicTo(
      size.width * 0.6825470,
      size.height * 0.3370844,
      size.width * 0.6507943,
      size.height * 0.3943434,
      size.width * 0.6159675,
      size.height * 0.4352243,
    );
    path_4.lineTo(size.width * 0.7684935, size.height * 0.3752083);
    path_4.close();

    drawEmbossedShape(path_4);

    Path path_5 = Path();
    path_5.moveTo(size.width * 0.5019459, size.height * 0.3947063);
    path_5.lineTo(size.width * 0.5124492, size.height * 0.2224856);
    path_5.lineTo(size.width * 0.5220146, size.height * 0.3789819);
    path_5.cubicTo(
      size.width * 0.5220146,
      size.height * 0.3789819,
      size.width * 0.5220299,
      size.height * 0.3789644,
      size.width * 0.5220299,
      size.height * 0.3789470,
    );
    path_5.lineTo(size.width * 0.5215052, size.height * 0.3961297);
    path_5.lineTo(size.width * 0.5200294, size.height * 0.4721128);
    path_5.cubicTo(
      size.width * 0.6205633,
      size.height * 0.4024920,
      size.width * 0.7537988,
      size.height * 0.2167441,
      size.width * 0.5124492,
      0,
    );
    path_5.cubicTo(
      size.width * 0.5124492,
      0,
      size.width * 0.3949119,
      size.height * 0.09707069,
      size.width * 0.3776286,
      size.height * 0.2222385,
    );
    path_5.cubicTo(
      size.width * 0.4424874,
      size.height * 0.2674221,
      size.width * 0.4806440,
      size.height * 0.3380530,
      size.width * 0.5019459,
      size.height * 0.3947063,
    );
    path_5.close();

    drawEmbossedShape(path_5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
