import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.55)],
            radius: 1.0,
            center: Alignment.topLeft,
          ),
        ),
      ),
    );
  }
}
