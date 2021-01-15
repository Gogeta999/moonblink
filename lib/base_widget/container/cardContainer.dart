import 'package:flutter/material.dart';
import 'package:moonblink/global/router_manager.dart';

class CardContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final VoidCallback ontap;
  CardContainer({this.child, this.color, this.ontap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: ontap,
        onLongPress: () => Navigator.of(context).pushNamed(RouteName.vipDemo),
        child: Container(
          height: 170,
          width: 350,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  // spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(-2, 3), // changes position of shadow
                ),
              ]),
          child: child,
        ),
      ),
    );
  }
}
