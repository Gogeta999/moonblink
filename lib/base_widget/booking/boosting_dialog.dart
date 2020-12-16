import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';

class BoostingDialog extends StatelessWidget {
  final int userId;
  final int bookingId;
  final int bookingUserId;
  final String bookingUserName;
  final String gameName;
  final int estimateCost;
  final int estimateDay;
  final int estimateHour;
  final String rankFrom;
  final String upToRank;
  final Function accept;
  final Function reject;

  const BoostingDialog(this.userId, this.bookingId, this.bookingUserId, this.bookingUserName, this.gameName, this.estimateCost, this.estimateDay, this.estimateHour, this.rankFrom, this.upToRank, this.accept, this.reject);


  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Boosting ' + G.of(context).bookingRequest),
      content: Text('$bookingUserName request Boosting Service for $gameName.\nFrom $rankFrom To $upToRank wihin $estimateDay days and $estimateHour hours for $estimateCost coins.'),
      actions: [
        CupertinoButton(
          child: Text(G.of(context).bookingDialogReject), 
          onPressed: () {
            reject();
            Navigator.pop(context);
          }),
        CupertinoButton(
          child: Text(G.of(context).bookingDialogAccept),
          onPressed: () {
            accept();
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
