import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// no matter our is in day or night mode, still have background color
/// so i save indicator into light color
class ActivityIndicator extends StatelessWidget {
  final double radius;
  final Brightness brightness;

  ActivityIndicator({this.radius, this.brightness});

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          cupertinoOverrideTheme: CupertinoThemeData(brightness: brightness),
        ),
        child: CupertinoActivityIndicator(radius: radius ?? 10));
  }
}
