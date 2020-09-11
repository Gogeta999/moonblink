import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';

class AppbarWidget extends StatefulWidget implements PreferredSizeWidget {
  bool nothome;
  AppbarWidget({this.nothome = false});

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
      // toolbarHeight: kToolbarHeight - 10,
      leading: widget.nothome
          ? IconButton(
              icon: Icon(Icons.backspace),
              onPressed: () => Navigator.pop(context),
            )
          : Container(),
      actions: [
        AppbarLogo(),
      ],
      bottom: PreferredSize(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                // spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 0), // changes position of shadow
              ),
            ],
          ),
          height: 10,
        ),
        preferredSize: Size.fromHeight(10),
      ),
    );
  }
}
