import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';

class AppbarWidget extends StatefulWidget implements PreferredSizeWidget {
  bool nothome;
  AppbarWidget({this.nothome = false});

  @override
  _AppbarWidgetState createState() => _AppbarWidgetState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 15);
}

class _AppbarWidgetState extends State<AppbarWidget> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: widget.nothome
          ? IconButton(
              icon: Icon(Icons.backspace),
              onPressed: () => Navigator.pop(context),
            )
          : Container(),
      actions: [AppbarLogo()],
      bottom: AppBar(
        leading: Container(),
        backgroundColor: Theme.of(context).accentColor,
        toolbarHeight: 20,
      ),
    );
  }
}
