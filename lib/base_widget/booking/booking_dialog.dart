import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';

class BookingDialog extends StatelessWidget {
  final String bookingUserName;
  final String gameName;
  final String type;
  final Function accept;
  final Function reject;

  const BookingDialog(
      {Key key, this.gameName, this.type, this.bookingUserName, this.accept, this.reject})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(G.of(context).bookingRequest),
      content: Text('$bookingUserName ' +
          G.of(context).bookingDialogSomeoneBook +
          '\n\n' + gameName + ' ' + type),
      actions: <Widget>[
        FlatButton(
            child: Text(G.of(context).bookingDialogReject),
            onPressed: () {
              reject();
              Navigator.pop(context, 'Reject');
            }),
        FlatButton(
          child: Text(G.of(context).bookingDialogAccept),
          onPressed: () {
            accept();
            Navigator.pop(context, 'Accept');
          },
        )
      ],
    );
  }
}
