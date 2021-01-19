import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/booking/booking_bottom_sheet.dart';
import 'package:moonblink/base_widget/photo_bottom_sheet.dart';
import 'package:moonblink/base_widget/top_up_bottom_sheet.dart';
import 'package:moonblink/base_widget/user_manage_content_bottom_sheet.dart';
import 'package:moonblink/base_widget/voice_bottom_sheet.dart';
import 'package:moonblink/bloc_pattern/update_game_profile/bloc/update_game_profile_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/game_profile.dart';
import 'package:moonblink/ui/pages/main/tutorial/gamepricedummy.dart';
import 'package:moonblink/view_model/booking_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
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
      @required bool willCrop,
      @required int compressQuality,
      bool defaultCropStyle = true,
      int minWidth = 1080,
      int minHeight = 1080,
      int vipLevel,
      Function onInit,
      Function onDismiss}) async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      //allow
      try {
        onInit();
      } catch (e) {
        if (e is NoSuchMethodError && isDev) print('NoSuchMethodError');
      }
      showModalBottomSheet(
          context: buildContext,
          barrierColor: Colors.black.withOpacity(0.6),
          isDismissible: true,
          isScrollControlled: true,
          builder: (context) => DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.5,
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
                      vipLevel: vipLevel,
                      willCrop: willCrop,
                      compressQuality: compressQuality,
                      defaultCropStyle: defaultCropStyle,
                    ),
                  );
                },
              )).whenComplete(() {
        try {
          onDismiss();
        } catch (e) {
          if (e is NoSuchMethodError && isDev) {
            print('NoSuchMethodError');
          }
        }
      });
    } else {
      // fail
      _permissionFail(buildContext, 'Photo');
    }
  }

  static showNewVoiceSheet(
      {@required BuildContext buildContext,
      @required Function(File file) send,
      Function onInit,
      Function onDismiss}) async {
    PermissionStatus permission = await Permission.microphone.status;
    if (permission == PermissionStatus.denied) {
      permission = await Permission.microphone.request();
    } else if (permission == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    } else if (permission == PermissionStatus.restricted) {
      showToast('Microphone access permission require to continue.');
      Navigator.pop(buildContext);
    }
    if (permission == PermissionStatus.granted) {
      showModalBottomSheet(
          context: buildContext,
          barrierColor: Colors.black.withOpacity(0.6),
          isDismissible: true,
          isScrollControlled: true,
          builder: (context) => DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.4,
                maxChildSize: 0.90,
                builder: (context, scrollController) {
                  return CircularBottomSheet(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: VoiceBottomSheet(send: send),
                  );
                },
              )).whenComplete(() {
        try {
          onDismiss();
        } catch (e) {
          if (e is NoSuchMethodError && isDev) {
            print('NoSuchMethodError');
          }
        }
      });
    }
  }

  static showUserManageContent(
      {@required BuildContext buildContext,
      @required Function onReport,
      @required Function onBlock,
      Function onDismiss}) async {
    showModalBottomSheet(
        context: buildContext,
        barrierColor: Colors.black.withOpacity(0.6),
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
        if (e is NoSuchMethodError && isDev) {
          print('NoSuchMethodError');
        }
      }
    });
  }

  static Future<dynamic> showGameModeBottomSheet(
      {@required BuildContext buildContext, Function onDismiss}) {
    return showModalBottomSheet(
        context: buildContext,
        barrierColor: Colors.black.withOpacity(0.6),
        isDismissible: true,
        builder: (context) => CircularBottomSheet(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: BlocProvider.value(
              value: BlocProvider.of<UpdateGameProfileBloc>(buildContext),
              child: GameModeBottomSheet(),
            ))).whenComplete(() {
      try {
        onDismiss();
      } catch (e) {
        if (e is NoSuchMethodError && isDev) {
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
        barrierColor: Colors.black.withOpacity(0.6),
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
        if (e is NoSuchMethodError && isDev) {
          print('NoSuchMethodError');
        }
      }
    });
  }

  static Future showTopUpBottomSheet(
      {@required BuildContext buildContext, Function onDismiss}) {
    return showModalBottomSheet(
        context: buildContext,
        barrierColor: Colors.black.withOpacity(0.6),
        isDismissible: true,
        builder: (context) => CircularBottomSheet(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TopUpBottomSheet())).whenComplete(() {
      try {
        onDismiss();
      } catch (e) {
        if (e is NoSuchMethodError && isDev) {
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
