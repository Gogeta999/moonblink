import 'package:flutter/cupertino.dart';
import 'package:moonblink/base_widget/vip_renew_dialog.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/utils/constants.dart';

void showviprenew(BuildContext context, int halfRenew) {
  if (halfRenew == 1) {
    print("++++++++++++++++++++++++++++++++++++++++++++++++++++");
    if (StorageManager.sharedPreferences.getString(renewDialog) != null) {
      String lastdate = StorageManager.sharedPreferences.getString(renewDialog);
      DateTime lastDatetime = DateTime.parse(lastdate);
      DateTime now = DateTime.now();
      final difference = now.difference(lastDatetime).inDays;
      print(difference);
      if (difference >= 1) {
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return VipRenewDialog();
          },
        );
      }
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return VipRenewDialog();
        },
      );
    }
  }
}
