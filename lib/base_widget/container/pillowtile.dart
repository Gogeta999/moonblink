import 'package:flutter/material.dart';

class PillowTile extends StatelessWidget {
  final Widget title;
  final Widget leading;
  PillowTile({@required this.title, this.leading});
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: Colors.white),
          borderRadius: BorderRadius.circular(110),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [title, leading],
        ));
  }
}
