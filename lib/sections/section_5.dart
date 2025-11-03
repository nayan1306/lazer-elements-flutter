import 'package:flutter/material.dart';

class Section5 extends StatefulWidget {
  const Section5({super.key});

  @override
  State<Section5> createState() => _Section5State();
}

class _Section5State extends State<Section5> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
