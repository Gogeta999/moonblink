import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// LoginPage Button
class LoginButtonWidget extends StatelessWidget {
  final Widget child;
  final Color color;
  final VoidCallback onPressed;

  LoginButtonWidget({this.child, this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    // var color = Theme.of(context).accentColor;
    return Padding(
        padding: const EdgeInsets.fromLTRB(15, 40, 15, 20),
        child: CupertinoButton(
          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
          color: color,
          disabledColor: color,
          borderRadius: BorderRadius.circular(110),
          pressedOpacity: 0.5,
          child: child,
          onPressed: onPressed,
        ));
  }
}
