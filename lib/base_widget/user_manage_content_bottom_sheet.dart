import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:oktoast/oktoast.dart';

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
          leading: Icon(Icons.report),
          title: Text(
            S.of(context).report,
            style: _textStyle,
          ),
          subtitle: Text(S.of(context).reportContent),
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
          trailing: isReporting ? CupertinoActivityIndicator() : Container(height: 0, width: 0),
        ),
        ListTile(
          leading: Icon(Icons.block),
          title: Text(
            'Block User',
            style: _textStyle,
          ),
          subtitle: Text(
              'This user won\'t see you or communicate with you anymore untill you remove him/her from your blocked list.'),
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
          trailing: isBlocking ? CupertinoActivityIndicator() : Container(height: 0, width: 0),
        ),
        SizedBox(height: 30)
      ],
    );
  }
}
