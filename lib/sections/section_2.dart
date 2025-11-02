import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Section2 extends StatelessWidget {
  const Section2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ModelViewer(
          src: 'assets/3d/earth.glb',
          alt: 'Earth 3D Model',
          autoRotate: true,
          cameraControls: true,
          backgroundColor: Colors.transparent,
          ar: false,
          arModes: const [],
          disableZoom: false,
        ),
      ),
    );
  }
}
