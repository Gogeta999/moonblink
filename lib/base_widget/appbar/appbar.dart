import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';

class AppbarWidget extends StatefulWidget implements PreferredSizeWidget {
  final Widget title;
  AppbarWidget({this.title});
  @override
  _AppbarWidgetState createState() => _AppbarWidgetState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 10);
}

class _AppbarWidgetState extends State<AppbarWidget> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: widget.title == null ? Container() : widget.title,
      // toolbarHeight: kToolbarHeight - 10,
      actions: [
        AppbarLogo(),
      ],
      bottom: PreferredSize(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).accentColor,
                // spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 0), // changes position of shadow
              ),
            ],
          ),
          height: 10,
        ),
        preferredSize: Size.fromHeight(5),
      ),
    );
  }
}
