import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_time_formatter.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/utils/constants.dart';

class VipRenewDialog extends StatefulWidget {
  @override
  _VipRenewDialogState createState() => _VipRenewDialogState();
}

class _VipRenewDialogState extends State<VipRenewDialog> {
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Vip Renew Discount'),
      content:
          Text('Your vip subscription is expired. Renew with half price now.'),
      actions: [
        CupertinoButton(
            child: Text(G.of(context).cancel),
            onPressed: () {
              String formatter = DateTimeFormatter.formatDate(
                  DateTime.now(), "yyyy-MM-dd", DateTimePickerLocale.en_us);
              StorageManager.sharedPreferences
                  .setString(renewDialog, formatter);
              Navigator.pop(context);
            }),
        CupertinoButton(
            child: Text(G.of(context).okay),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteName.upgradeVip,
                  arguments: {'acc_vip_level': "0", 'half_renew': 1});
            })
      ],
    );
  }
}
