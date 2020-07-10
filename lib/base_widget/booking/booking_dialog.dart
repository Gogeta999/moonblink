import 'package:flutter/material.dart';

class BookingDialog extends StatelessWidget {
  final Function accept;
  final Function decline;

  const BookingDialog({Key key, this.accept, this.decline}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Booking dialog'),
      content: Text('Somone want to play with you'),
      actions: <Widget>[
        FlatButton(
            child: Text('Decline'),
            onPressed: () {
              print('Decline');
              decline();
              Navigator.pop(context, 'Decline');
            }),
        FlatButton(
          child: Text('Accept'),
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
