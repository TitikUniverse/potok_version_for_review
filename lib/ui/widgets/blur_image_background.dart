import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/potok_theme.dart';

class BlurImageBackground extends StatelessWidget {
  const BlurImageBackground({super.key, required this.imagePath, this.opacity = .9});

  final double opacity;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRect(
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Image.asset(imagePath, fit: BoxFit.cover)
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: PotokTheme.of(context).backgroundColor.withOpacity(opacity),
          ),
        ),
      ],
    );
  }
}