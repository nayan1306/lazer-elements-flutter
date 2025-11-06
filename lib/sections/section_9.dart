import 'package:flutter/material.dart';

class Section9 extends StatefulWidget {
  const Section9({super.key});

  @override
  State<Section9> createState() => _Section9State();
}

class _Section9State extends State<Section9> with TickerProviderStateMixin {
  late AnimationController _scrollAnimationController;

  @override
  void initState() {
    super.initState();
    _scrollAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _scrollAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth * 0.8;
    final containerHeight = screenHeight * 0.7;

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    final titles = [
      'Innovation',
      'Technology',
      'Creativity',
      'Excellence',
      'Future',
    ];

    final descriptions = [
      'Pushing boundaries with cutting-edge solutions',
      'Harnessing the power of modern tech',
      'Unleashing creative potential',
      'Delivering superior quality results',
      'Building tomorrow\'s possibilities',
    ];

    // Portrait card dimensions (taller than wide)
    final cardWidth = 200.0;
    final cardHeight = 360.0;
    final cardSpacing = 40.0;
    final totalCardWidth = cardWidth + cardSpacing;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: containerWidth,
          height: containerHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _scrollAnimationController,
                    builder: (context, child) {
                      // Calculate the offset for horizontal scrolling
                      // Move cards from right to left
                      final totalWidth = totalCardWidth * 5;
                      final scrollOffset =
                          (_scrollAnimationController.value * totalWidth) %
                          totalWidth;

                      return Positioned(
                        left: -scrollOffset,
                        top: (containerHeight - cardHeight) / 2,
                        child: Row(
                          children: [
                            // Create multiple sets of cards for seamless looping
                            for (int set = 0; set < 3; set++)
                              for (int i = 0; i < 5; i++)
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: i < 4
                                        ? cardSpacing
                                        : (set < 2 ? cardSpacing : 0),
                                  ),
                                  child: AnimatedCard(
                                    width: cardWidth,
                                    height: cardHeight,
                                    color: colors[i],
                                    title: titles[i],
                                    description: descriptions[i],
                                  ),
                                ),
                          ],
                        ),
                      );
                    },
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

class AnimatedCard extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final String title;
  final String description;

  const AnimatedCard({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _rotationAnimation = CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutCubic,
    );
    // Start with card lying almost flat (80 degrees, content partially visible)
    _rotationController.value = 0.0;
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _rotationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _rotationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          // Rotate from 80 degrees (lying almost flat, content partially visible) to 0 degrees (completely straight/vertical)
          // Animation value 0 = lying flat, value 1 = upright
          final rotation = 80.0 - (_rotationAnimation.value * 80.0);

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateX(-rotation * 3.14159 / 180.0), // Convert to radians
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_isHovered ? 0.7 : 0.3),
                    blurRadius: _isHovered ? 30 : 20,
                    spreadRadius: _isHovered ? 8 : 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
