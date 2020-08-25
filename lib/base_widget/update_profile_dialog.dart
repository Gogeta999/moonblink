import 'package:flutter/material.dart';
import 'package:moonblink/models/partner.dart';

class UpdateProfileDialog extends StatelessWidget {
  final PartnerUser partnerUser;
  final Function navigateToProfilePage;

  const UpdateProfileDialog({Key key, this.partnerUser, this.navigateToProfilePage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      title: Text('Your profile is missing some games ID'),
      content: Text('Please fill your game ID at profile.'),
      actions: <Widget>[
        FlatButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context)),
        FlatButton(
          child: Text('Okay'),
          onPressed: () => navigateToProfilePage(),
        )
      ],
    );
  }
}