import 'package:flutter/material.dart';

class BookingDialog extends StatelessWidget {
  final Function accept;
  final Function reject;

  const BookingDialog({Key key, this.accept, this.reject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Booking dialog'),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)),
      content: Text('Somone want to play with you'),
      actions: <Widget>[
        FlatButton(
            child: Text('Reject'),
            onPressed: () {
              print('Rejected');
              reject();
              Navigator.pop(context, 'Reject');
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
