import 'package:flutter/material.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:moonblink/utils/constants.dart';

import 'booking_dialog.dart';

const int BOOKING_ACCEPT = 1;
const int BOOKING_REJECT = 2;

class BookingManager {
  int _userId;
  int _bookingId;
  int _bookingUserId;
  String _bookingUserName;
  String _gameName;
  String _type; ///Eg - Classic

  void bookingPrepare({int userId, int bookingId, int bookingUserId, String bookingUserName, String gameName, String type}){
    this._userId = userId;
    this._bookingId = bookingId;
    this._bookingUserId = bookingUserId;
    this._bookingUserName = bookingUserName;
    this._gameName = gameName;
    this._type = type;
  }

  void bookingAccept() {
    MoonBlinkRepository.bookingAcceptOrDecline(_userId, _bookingId, BOOKING_ACCEPT).then((value) =>
        value != null
            ? (){
              bool atChatBox = StorageManager.sharedPreferences.getBool(isUserAtChatBox);
              if (!atChatBox)
                locator<NavigationService>()
                .navigateTo(RouteName.chatBox, arguments: _bookingUserId);
            }
            : null);
  }

  void bookingReject() {
    MoonBlinkRepository.bookingAcceptOrDecline(_userId, _bookingId, BOOKING_REJECT);
  }

  void showBookingDialog() {
    if (_gameName.isEmpty || _type.isEmpty) return;
    showDialog(
      context: locator<NavigationService>().navigatorKey.currentState.overlay.context,
      builder: (context) => BookingDialog(
          bookingUserName: _bookingUserName,
          gameName: _gameName,
          type: _type,
          accept: bookingAccept,
          reject: bookingReject,
      )
    );
  }
}
