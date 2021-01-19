import 'package:flutter/material.dart';

class LoginFormContainer extends StatelessWidget {
  final Widget child;

  LoginFormContainer({Key key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: ShapeDecoration(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.black,
          shadows: [
            BoxShadow(
                color: Theme.of(context).primaryColor.withAlpha(20),
                offset: Offset(1.0, 1.0),
                blurRadius: 10.0,
                spreadRadius: 3.0),
          ]),
      child: child,
    );
  }
}
