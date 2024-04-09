import 'package:blog_bloom/core/theme/app_palette.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppPalette.gradient2),
        strokeWidth: 2,
        backgroundColor: Colors.white,
      ),
    );
  }
}
