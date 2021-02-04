import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_time_formatter.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:moonblink/base_widget/customDialog_widget.dart';
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
    return CustomDialog(
      title: G.current.halfPriceDialogTitle,
      simpleContent: G.current.halfPriceDialogContent,
      confirmCallback: () {
        Navigator.pushNamed(
          context,
          RouteName.upgradeVip,
        );
      },
      cancelColor: Theme.of(context).accentColor,
      confirmButtonColor: Theme.of(context).accentColor,
      confirmContent: G.current.confirm,
      cancelContent: G.current.cancel,
      dismissCallback: () {
        String formatter = DateTimeFormatter.formatDate(
            DateTime.now(), "yyyy-MM-dd", DateTimePickerLocale.en_us);
        StorageManager.sharedPreferences.setString(renewDialog, formatter);
      },
    );
  }
}
