import 'package:flutter/material.dart';

class ShadedContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final Function ontap;
  final bool selected;
  final Color color;
  ShadedContainer(
      {this.child, this.height, this.ontap, this.color, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        height: height,
        padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
        decoration: BoxDecoration(
          color:
              color == null ? Theme.of(context).scaffoldBackgroundColor : color,
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

class SmallShadedContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final Function ontap;
  final Function onDoubletap;
  final bool selected;
  SmallShadedContainer(
      {this.child,
      this.height,
      this.ontap,
      this.onDoubletap,
      this.selected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      onDoubleTap: onDoubletap,
      child: Container(
        width: 80,
        height: height,
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: selected ? Theme.of(context).accentColor : Colors.black,
              spreadRadius: 1,
              // blurRadius: 2,
              offset: Offset(-2, 2), // changes position of shadow
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class MediumShadedContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final Function ontap;
  final bool selected;
  MediumShadedContainer(
      {this.child, this.height, this.ontap, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: 130,
        height: height,
        padding: EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: selected ? Theme.of(context).accentColor : Colors.black,
              spreadRadius: 1,
              // blurRadius: 2,
              offset: Offset(-2, 2), // changes position of shadow
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
