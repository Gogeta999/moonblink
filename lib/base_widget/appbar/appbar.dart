import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/ui/helper/icons.dart';

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
      leading: Navigator.of(context).canPop() ? IconButton(
          icon: SvgPicture.asset(
            back,
            semanticsLabel: 'back',
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).accentColor
                : Colors.white,
            width: 30,
            height: 30,
          ),
          onPressed: () => Navigator.pop(context)) : Container(),
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
