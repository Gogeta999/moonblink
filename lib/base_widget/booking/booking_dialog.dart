import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';

///TODO - GameName and Type need to fix
const List<String> gameList = [
  'Mobile Legends - Classic',
  'Mobile Legends - Rank',
  'PUBG - Rank',
  'PUBG - Arcade'
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
    return CupertinoAlertDialog(
      title: Text(G.of(context).bookingDialog),
// =======
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//       title: Text(G.of(context).bookingDialog),
// >>>>>>> develop-master
      content: Text('$bookingUserName ' +
          G.of(context).bookingDialogSomeoneBook +
          '\n\n' +
          'Game : ${gameList[gameType]}'),
      actions: <Widget>[
        FlatButton(
            child: Text(G.of(context).bookingDialogReject),
            onPressed: () {
              print('Rejected');
              reject();
              Navigator.pop(context, 'Reject');
            }),
        FlatButton(
          child: Text(G.of(context).bookingDialogAccept),
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
