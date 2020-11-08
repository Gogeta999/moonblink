import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final double bottom;
  final double top;
  final double left;
  final double right;
  final Animation<double> scale;
  // final double angle;
  final Widget child;
  FloatingButton(
      {this.bottom, this.top, this.left, this.right, this.scale, this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottom,
      left: left,
      child: new Container(
        child: new Row(
          children: <Widget>[
            new ScaleTransition(
              scale: scale,
              alignment: FractionalOffset.center,
              child: ClipOval(
                child: new Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(120),
                  ),
                  width: 45.0,
                  height: 45.0,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
