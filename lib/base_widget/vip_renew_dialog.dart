import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';

class VipRenewDialog extends StatefulWidget {
  @override
  _VipRenewDialogState createState() => _VipRenewDialogState();
}

class _VipRenewDialogState extends State<VipRenewDialog> {
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Vip Renew Discount'),
      content: Text('Your vip subscription is expired. Renew with half price now.'),
      actions: [
        CupertinoButton(child: Text(G.of(context).cancel), onPressed: () => Navigator.pop(context)),
        CupertinoButton(child: Text(G.of(context).okay), onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, RouteName.upgradeVip, arguments: {'acc_vip_level': "0", 'half_renew': 1});
        })
      ],
    );
  }
}