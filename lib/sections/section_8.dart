import 'package:flutter/material.dart';

class Section8 extends StatefulWidget {
  const Section8({super.key});

  @override
  State<Section8> createState() => _Section8State();
}

class _Section8State extends State<Section8> {
  int? _hoveredCardIndex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.1;
    final baseOffset = -screenHeight * 0.1 * 1.7;
    final overlapOffset = screenHeight * 0.1 * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: screenWidth * 0.6,
          height: screenHeight * 0.5,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(20),
          ),
          child: MouseRegion(
            onHover: (event) {
              // Calculate which card the mouse is over based on Y position
              final localPosition = event.localPosition;
              final containerHeight = screenHeight * 0.5;
              final centerY = containerHeight / 2;
              final relativeY = localPosition.dy - centerY;

              // Check from top card down (highest index first) so topmost card gets hover
              int? foundIndex;
              for (int i = 5; i >= 0; i--) {
                final cardY = baseOffset + (overlapOffset * i);
                final cardTop = cardY - cardHeight / 2;
                final cardBottom = cardY + cardHeight / 2;

                if (relativeY >= cardTop && relativeY <= cardBottom) {
                  foundIndex = i;
                  break;
                }
              }

              if (foundIndex != null && _hoveredCardIndex != foundIndex) {
                setState(() => _hoveredCardIndex = foundIndex);
              } else if (foundIndex == null && _hoveredCardIndex != null) {
                setState(() => _hoveredCardIndex = null);
              }
            },
            onExit: (_) {
              setState(() => _hoveredCardIndex = null);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (int i = 0; i < 6; i++)
                  AnimatedScale(
                    scale: _hoveredCardIndex == i ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      transform: Matrix4.identity()
                        ..translate(
                          0.0,
                          _hoveredCardIndex == i
                              ? -screenHeight * 0.1 * 0.2
                              : 0.0,
                        ),
                      child: Transform.translate(
                        // Calculate offset: each card overlaps by 20% (moves by 80% of card height)
                        // Total height with 4 cards: h + 3*(0.8h) = 3.4h
                        // To center: start at -1.7h, then each card at -1.7h + i*0.8h
                        offset: Offset(0, baseOffset + (overlapOffset * i)),
                        child: ContentCard(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          color: Colors.grey[300 + (i * 100)] ?? Colors.grey,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    this.title,
    this.description,
    this.color,
  });
  final String? title;
  final String? description;
  final double screenWidth;
  final double screenHeight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.5,
      height: screenHeight * 0.1,
      decoration: BoxDecoration(
        color: color ?? Colors.white24,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [Text(title ?? ''), Text(description ?? '')]),
    );
  }
}
