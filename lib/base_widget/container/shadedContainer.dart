import 'package:flutter/material.dart';

class ShadedContainer extends StatelessWidget {
  final Widget child;
  final Function ontap;
  final bool selected;
  ShadedContainer({this.child, this.ontap, this.selected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: selected ? Theme.of(context).accentColor : Colors.grey,
              spreadRadius: 1,
              // blurRadius: 2,
              offset: Offset(-5, 3), // changes position of shadow
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
