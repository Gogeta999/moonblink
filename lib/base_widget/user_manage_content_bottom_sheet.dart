import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';

class UserManageContentBottomSheet extends StatefulWidget {
  final Function onReport;
  final Function onBlock;

  const UserManageContentBottomSheet(
      {Key key, @required this.onReport, @required this.onBlock})
      : super(key: key);
  @override
  _UserManageContentBottomSheetState createState() =>
      _UserManageContentBottomSheetState();
}

class _UserManageContentBottomSheetState
    extends State<UserManageContentBottomSheet> {
  TextStyle _textStyle;

  bool isBlocking = false;
  bool isReporting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textStyle = Theme.of(context).textTheme.bodyText1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.report, color: Theme.of(context).accentColor),
          title: Text(
            G.of(context).report,
            style: _textStyle,
          ),
          subtitle: Text(G.of(context).reportContent),
          onTap: () async {
            setState(() {
              isReporting = true;
            });
            await widget.onReport();
            setState(() {
              isReporting = false;
            });

            ///Reporting api call.
          },
          trailing: isReporting
              ? CupertinoActivityIndicator()
              : Container(height: 0, width: 0),
        ),
        ListTile(
          leading: Icon(Icons.block, color: Theme.of(context).accentColor),
          title: Text(
            G.of(context).block,
            style: _textStyle,
          ),
          subtitle: Text(G.of(context).blockContent),
          onTap: () async {
            setState(() {
              isBlocking = true;
            });
            await widget.onBlock();
            setState(() {
              isBlocking = false;
            });

            ///Blocking api call.
          },
          trailing: isBlocking
              ? CupertinoActivityIndicator()
              : Container(height: 0, width: 0),
        ),
        SizedBox(height: 30)
      ],
    );
  }
}
