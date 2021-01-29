import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/ui/helper/icons.dart';

class AppbarWidget extends StatefulWidget implements PreferredSizeWidget {
  final Widget title;
  final Function leadingCallback;
  final Icon leadingIcon;
  final String leadingText;
  final bool showBack;
  final bool showActionIcon;
  AppbarWidget(
      {this.title,
      this.leadingCallback,
      this.leadingIcon,
      this.leadingText,
      this.showBack = true,
      this.showActionIcon = true});
  @override
  _AppbarWidgetState createState() => _AppbarWidgetState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 10);
}

class _AppbarWidgetState extends State<AppbarWidget> {
  _leadingFunction() {
    if (widget.leadingIcon != null) {
      return IconButton(
          icon: widget.leadingIcon == null
              ? SvgPicture.asset(
                  followingfilled,
                  semanticsLabel: '',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).accentColor
                      : Colors.white,
                  width: 30,
                  height: 30,
                )
              : widget.leadingIcon,
          onPressed: () => widget.leadingCallback());
    }
    if (widget.leadingText != null) {
      return TextButton(
        child: widget.leadingText == null
            ? SvgPicture.asset(
                back,
                semanticsLabel: '',
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).accentColor
                    : Colors.white,
                width: 30,
                height: 30,
              )
            : Text(
                widget.leadingText,
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).accentColor
                      : Colors.white,
                ),
              ),
        onPressed: () => widget.leadingCallback(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 80,

      leading: widget.leadingCallback == null
          ? Navigator.of(context).canPop() && widget.showBack
              ? IconButton(
                  icon: SvgPicture.asset(
                    back,
                    semanticsLabel: 'back',
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).accentColor
                        : Colors.white,
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () => Navigator.pop(context))
              : Container()
          : _leadingFunction(),
      backgroundColor: Colors.black,
      title: widget.title == null ? Container() : widget.title,
      // toolbarHeight: kToolbarHeight - 10,

      actions: widget.showActionIcon == true
          ? [
              AppbarLogo(),
            ]
          : null,
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
