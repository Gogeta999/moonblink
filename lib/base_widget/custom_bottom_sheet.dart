import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:moonblink/base_widget/booking/booking_bottom_sheet.dart';
import 'package:moonblink/base_widget/photo_bottom_sheet.dart';
import 'package:moonblink/base_widget/top_up_bottom_sheet.dart';
import 'package:moonblink/base_widget/user_manage_content_bottom_sheet.dart';
import 'package:moonblink/base_widget/voice_bottom_sheet.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/game_profile.dart';
import 'package:moonblink/view_model/booking_model.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'game_mode_bottom_sheet.dart';

class CustomBottomSheet {
  // ignore: non_constant_identifier_names
  static Widget CircularBottomSheet({Widget child, Color color}) {
    return Container(
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15.0),
            topRight: const Radius.circular(15.0),
          )),
      child: child,
    );
  }

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
          barrierColor: Colors.white.withOpacity(0.15),
          isDismissible: true,
          isScrollControlled: true,
          builder: (context) => DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.4,
                maxChildSize: 0.90,
                builder: (context, scrollController) {
                  return CircularBottomSheet(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: PhotoBottomSheet(
                      sheetScrollController: scrollController,
                      popAfterBtnPressed: popAfterBtnPressed,
                      requestType: requestType,
                      limit: limit,
                      onPressed: onPressed,
                      body: body,
                      buttonText: buttonText,
                      minWidth: minWidth,
                      minHeight: minHeight,
                    ),
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
          barrierColor: Colors.white.withOpacity(0.15),
          isDismissible: true,
          isScrollControlled: true,
          builder: (context) => DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.4,
                maxChildSize: 0.90,
                builder: (context, scrollController) {
                  return CircularBottomSheet(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: VoiceBottomSheet(
                        send: send,
                        cancel: cancel,
                        start: start,
                        restart: restart),
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
        barrierColor: Colors.white.withOpacity(0.15),
        isDismissible: true,
        builder: (context) => CircularBottomSheet(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: UserManageContentBottomSheet(
                onReport: onReport,
                onBlock: onBlock,
              ),
            )).whenComplete(() {
      try {
        onDismiss();
      } catch (e) {
        if (e is NoSuchMethodError) {
          print('NoSuchMethodError');
        }
      }
    });
  }

  static showGameModeBottomSheet(
      {@required BuildContext buildContext,
      @required List<GameMode> gameModeList,
      @required List<int> selectedGameModeIndex,
      @required Function onDone,
      Function onDismiss}) {
    showModalBottomSheet(
        context: buildContext,
        barrierColor: Colors.white.withOpacity(0.15),
        isDismissible: true,
        builder: (context) => CircularBottomSheet(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: GameModeBottomSheet(
              gameModeList: gameModeList,
              selectedGameModeIndex: selectedGameModeIndex,
              onDone: onDone,
            ))).whenComplete(() {
      try {
        onDismiss();
      } catch (e) {
        if (e is NoSuchMethodError) {
          print('NoSuchMethodError');
        }
      }
    });
  }

  static showBookingSheet(
      {@required BuildContext buildContext,
      @required BookingModel model,
      @required int partnerId,
      Function onDismiss}) {
    showModalBottomSheet(
        context: buildContext,
        barrierColor: Colors.white.withOpacity(0.15),
        isDismissible: true,
        builder: (context) => Provider.value(
              value: model,
              child: CircularBottomSheet(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: BookingBottomSheet(partnerId: partnerId),
              ),
            )).whenComplete(() {
      try {
        onDismiss();
      } catch (e) {
        if (e is NoSuchMethodError) {
          print('NoSuchMethodError');
        }
      }
    });
  }

  static Future showTopUpBottomSheet(
      {@required BuildContext buildContext, Function onDismiss}) {
    return showModalBottomSheet(
        context: buildContext,
        barrierColor: Colors.white.withOpacity(0.15),
        isDismissible: false,
        builder: (context) => CircularBottomSheet(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TopUpBottomSheet())).whenComplete(() {
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
              title: Text(G.of(context).permissiondenied,
                  style: Theme.of(context).textTheme.headline6),
              content: Text(
                  'Allow $permissionName permission in settings to continue',
                  style: Theme.of(context).textTheme.bodyText1),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(G.of(context).cancel,
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
              title: Text(G.of(context).permissiondenied),
              titleTextStyle: Theme.of(context).textTheme.headline6,
              content: Text(
                  'Allow $permissionName permission in settings to continue',
                  style: Theme.of(context).textTheme.bodyText1),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(G.of(context).cancel,
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
