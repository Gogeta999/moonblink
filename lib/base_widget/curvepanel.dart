import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/BottomClipper.dart';

class FirstCurvePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BottomClipper1(),
      child: Container(
        height: MediaQuery.of(context).size.height / 1.4,
        color: Colors.black,
      ),
    );
  }
}

class SecCurvePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return ClipPath(
      clipper: BottomClipper2(),
      child: Container(
          height: MediaQuery.of(context).size.height / 1.3,
          color: theme.accentColor),
    );
  }
}

class UserStatusCurve extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return ClipPath(
      clipper: BottomClipper2(),
      child: Container(
          height: MediaQuery.of(context).size.height / 2.8,
          color: theme.accentColor),
    );
  }
}
