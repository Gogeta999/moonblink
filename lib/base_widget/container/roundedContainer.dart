import 'package:flutter/material.dart';

class RoundedContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final Color color;
  RoundedContainer({this.child, this.height, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      shadowColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.grey,
      elevation: 4,
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        width: MediaQuery.of(context).size.width,
        height: height,
        // decoration: BoxDecoration(
        //   border: Border.all(
        //       width: 1,
        //       color: Theme.of(context).brightness == Brightness.dark
        //           ? Colors.grey
        //           : Colors.black),
        //   color: color,
        //   borderRadius: BorderRadius.all(Radius.circular(100)),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Theme.of(context).brightness == Brightness.dark
        //           ? Colors.black
        //           : Colors.black,
        //       // spreadRadius: 2,
        //       blurRadius: 4,
        //       offset: Offset(-2, 3), // changes position of shadow
        //     ),
        //   ],
        // ),
        child: child == null ? Container() : child,
      ),
    );
  }
}
