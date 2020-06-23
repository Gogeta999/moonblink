import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/BottomClipper.dart';

class TopCurvePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BottomClipper(),
      child: Container(
        height: 220,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}