import 'package:flutter/material.dart';

class ShadedContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final Function ontap;
  ShadedContainer({this.child, this.height, this.ontap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        height: height,
        padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              spreadRadius: 1,
              // blurRadius: 2,
              offset: Offset(-5, 5), // changes position of shadow
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
