import 'package:flutter/material.dart';

class ShadedContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final Function ontap;
  final bool selected;
  ShadedContainer({this.child, this.height, this.ontap, this.selected = false});

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
              color: selected ? Theme.of(context).accentColor : Colors.black,
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
