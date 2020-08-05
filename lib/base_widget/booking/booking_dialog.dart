import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';

const List<String> gameList = [
  'Mobile Legends - Classic',
  'Mobile Legends - Rank',
  'Pubg - Classic',
  'Pubg - Rank'
];

class BookingDialog extends StatelessWidget {
  final String bookingUserName;
  final int gameType;
  final Function accept;
  final Function reject;

  const BookingDialog(
      {Key key, this.bookingUserName, this.gameType, this.accept, this.reject})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(S.of(context).bookingDialog),
      content: Text('$bookingUserName ' +
          S.of(context).bookingDialogSomeoneBook +
          '\n\n' +
          'Game : ${gameList[gameType]}'),
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
