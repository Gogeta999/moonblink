import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class UserManageContentBottomSheet extends StatefulWidget {
  final Function onReport;
  final Function onBlock;

  const UserManageContentBottomSheet({Key key, @required this.onReport, @required this.onBlock}) : super(key: key);
  @override
  _UserManageContentBottomSheetState createState() => _UserManageContentBottomSheetState();
}

class _UserManageContentBottomSheetState extends State<UserManageContentBottomSheet> {
  TextStyle _textStyle;

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
          title: Text('Report User',
            style: _textStyle,
          ),
          subtitle: Text('Report user for posting objectionable content.'),
          onTap: (){
            showToast('Reporting');
            widget.onReport();
            ///Reporting api call.
          },
        ),
        ListTile(
          leading: Icon(Icons.block),
          title: Text('Block User',
            style: _textStyle,
          ),
          subtitle: Text('This user won\'t see you or communicate with you anymore untill you remove him/her from your blocked list.'),
          onTap: (){
            showToast('Blocking');
            widget.onBlock();
            ///Blocking api call.
          },
        ),
        /*ListTile(///Testing State
          leading: Icon(Icons.remove_circle),
          title: Text('Unfollow User',
            style: _textStyle,
          ),
          subtitle: Text('Remove user from your following list. You won\'t see his/her stories anymore.'),
          onTap: (){
            showToast('Unfollowing');
            ///Unfollowing api call.
          },
        ),*/
        SizedBox(height: 40)
      ],
    );
  }
}