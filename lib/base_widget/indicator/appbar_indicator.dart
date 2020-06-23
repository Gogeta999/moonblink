import 'package:flutter/material.dart';

import 'activity_indicator.dart';

/// no matter our is in day or night mode, still have background color
/// so i save indicator into light color
class AppBarIndicator extends StatelessWidget {
  final double radius;

  AppBarIndicator({this.radius});

  @override
  Widget build(BuildContext context) {
    return ActivityIndicator(
      brightness: Brightness.dark,
      radius: radius,
    );
  }
}
