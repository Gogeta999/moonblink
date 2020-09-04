import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';

class AppbarWidget extends StatefulWidget implements PreferredSizeWidget {
  const AppbarWidget({Key key}) : super(key: key);

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
      actions: [AppbarLogo()],
      bottom: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        toolbarHeight: 20,
      ),
    );
  }
}
