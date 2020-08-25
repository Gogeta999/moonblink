import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:moonblink/base_widget/photo_bottom_sheet.dart';
import 'package:moonblink/base_widget/user_manage_content_bottom_sheet.dart';
import 'package:moonblink/base_widget/voice_bottom_sheet.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:photo_manager/photo_manager.dart';

class CustomBottomSheet {
  static show(
      {@required BuildContext buildContext,
      @required int limit,
      @required String body,
      @required Function onPressed,
      @required String buttonText,
      @required bool popAfterBtnPressed,
      @required RequestType requestType,
      int minWidth = 1080,
      int minHeight = 1080,
      Function onInit,
      Function onDismiss}) async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      //allow
      try {
        onInit();
      } catch (e) {
        if (e is NoSuchMethodError) print('NoSuchMethodError');
      }
      showModalBottomSheet(
          context: buildContext,
          barrierColor: Colors.white.withOpacity(0.0),
          isDismissible: true,
          isScrollControlled: true,
          builder: (context) => DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.4,
                maxChildSize: 0.90,
                builder: (context, scrollController) {
                  return PhotoBottomSheet(
                    sheetScrollController: scrollController,
                    popAfterBtnPressed: popAfterBtnPressed,
                    requestType: requestType,
                    limit: limit,
                    onPressed: onPressed,
                    body: body,
                    buttonText: buttonText,
                    minWidth: minWidth,
                    minHeight: minHeight,
                  );
                },
              )).whenComplete(() {
        try {
          onDismiss();
        } catch (e) {
          if (e is NoSuchMethodError) {
            print('NoSuchMethodError');
          }
        }
      });
    } else {
      // fail
      _permissionFail(buildContext, 'Photo');
    }
  }

  static showVoiceSheet(
      {@required BuildContext buildContext,
      @required Function send,
      @required Function cancel,
      @required Function start,
      @required Function restart,
      Function onInit,
      Function onDismiss}) async {
    ///request permission with async
    bool permission = await FlutterAudioRecorder.hasPermissions;
    if (permission) {
      try {
        onInit();
      } catch (e) {
        if (e is NoSuchMethodError) print('NoSuchMethodError');
      }
      showModalBottomSheet(
          context: buildContext,
          barrierColor: Colors.white.withOpacity(0.0),
          isDismissible: true,
          isScrollControlled: true,
          builder: (context) => DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.4,
                maxChildSize: 0.90,
                builder: (context, scrollController) {
                  return VoiceBottomSheet(
                      send: send,
                      cancel: cancel,
                      start: start,
                      restart: restart);
                },
              )).whenComplete(() {
        try {
          onDismiss();
        } catch (e) {
          if (e is NoSuchMethodError) {
            print('NoSuchMethodError');
          }
        }
      });
    } else {
      _permissionFail(buildContext, 'Microphone');
    }
  }

  static showUserManageContent(
      {@required BuildContext buildContext,
        @required Function onReport,
        @required Function onBlock,
        Function onDismiss}) async {
      showModalBottomSheet(
          context: buildContext,
          barrierColor: Colors.white.withOpacity(0.0),
          isDismissible: true,
          builder: (context) => UserManageContentBottomSheet(
            onReport: onReport,
            onBlock: onBlock,
          )
          ).whenComplete(() {
        try {
          onDismiss();
        } catch (e) {
          if (e is NoSuchMethodError) {
            print('NoSuchMethodError');
          }
        }
      });
  }

  static _permissionFail(BuildContext buildContext, String permissionName) {
    showDialog(
        context: buildContext,
        builder: (context) {
          if (Platform.isIOS) {
            return CupertinoAlertDialog(
              title: Text(S.of(context).permissiondenied,
                  style: Theme.of(context).textTheme.headline6),
              content: Text(
                  'Allow $permissionName permission in settings to continue',
                  style: Theme.of(context).textTheme.bodyText1),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context).cancel,
                      style: Theme.of(context).textTheme.bodyText1),
                ),
                FlatButton(
                  onPressed: () => PhotoManager.openSetting(),
                  child: Text('Open Settings',
                      style: Theme.of(context).textTheme.bodyText1),
                )
              ],
            );
          } else {
            return AlertDialog(
              title: Text(S.of(context).permissiondenied),
              titleTextStyle: Theme.of(context).textTheme.headline6,
              content: Text(
                  'Allow $permissionName permission in settings to continue',
                  style: Theme.of(context).textTheme.bodyText1),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context).cancel,
                      style: Theme.of(context).textTheme.bodyText1),
                ),
                FlatButton(
                  onPressed: () => PhotoManager.openSetting(),
                  child: Text('Open Settings',
                      style: Theme.of(context).textTheme.bodyText1),
                )
              ],
            );
          }
        });
  }
}

