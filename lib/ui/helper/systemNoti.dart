import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/systemDialog_widget.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:oktoast/oktoast.dart';

void systemNoti() async {
  showDialog(
      context: locator<NavigationService>()
          .navigatorKey
          .currentState
          .overlay
          .context,
      builder: (_) {
        return SystemDialog(
          title: 'Here is Title',
          simpleContent:
              'A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. A lot of. ',
          // row1Content: 'Row1',
          // row2Content: Text('Row2'),
          cancelContent: 'Cancel',
          isCancel: true, // if True Then cancel button will exist
          cancelColor: Theme.of(locator<NavigationService>()
                  .navigatorKey
                  .currentState
                  .overlay
                  .context)
              .accentColor,
          confirmButtonColor: Theme.of(locator<NavigationService>()
                  .navigatorKey
                  .currentState
                  .overlay
                  .context)
              .accentColor,
          confirmContent: 'Confirm',
          confirmCallback: () {
            showToast('Make Navigate Here');
          },
          // image: ImageHelper.wrapAssetsImage('MoonBlinkProfile.jpg'),
          // imageHintText: 'Here is Hint',
        );
      });
}
