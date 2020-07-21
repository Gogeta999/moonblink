import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';

class BookingDialog extends StatelessWidget {
  final Function accept;
  final Function reject;

  const BookingDialog({Key key, this.accept, this.reject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).bookingDialog),
      //TODO: change someone to customer name late
      content: Text('Somone' + S.of(context).bookingDialogSomeoneBook),
      actions: <Widget>[
        FlatButton(
            child: Text(S.of(context).bookingDialogReject),
            onPressed: () {
              print('Rejected');
              reject();
              Navigator.pop(context, 'Reject');
            }),
        FlatButton(
          child: Text(S.of(context).bookingDialogAccept),
          onPressed: () {
            print('Accepted');
            accept();
            Navigator.pop(context, 'Accept');
          },
        )
      ],
    );
  }
}
