import 'package:blog_bloom/core/theme/app_palette.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({Key? key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppPalette.gradient2), // Color of the indicator
        strokeWidth: 2, // Adjust the thickness of the indicator
        backgroundColor: Colors.white, // Background color of the indicator
      ),
    );
  }
}
