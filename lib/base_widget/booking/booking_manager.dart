import 'package:flutter/material.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/navigation_service.dart';

import 'booking_dialog.dart';

const int BOOKING_ACCEPT = 1;
const int BOOKING_REJECT = 2;

class BookingManager {
  int _userId;
  int _bookingId;
  int _bookingUserId;
  String _bookingUserName;
  int _gameType;

  void bookingPrepare({int userId, int bookingId, int bookingUserId, String bookingUserName, int gameType}){
    this._userId = userId;
    this._bookingId = bookingId;
    this._bookingUserId = bookingUserId;
    this._bookingUserName = bookingUserName;
    this._gameType = gameType;
  }

  void bookingAccept() {
    MoonBlinkRepository.bookingAcceptOrDecline(_userId, _bookingId, BOOKING_ACCEPT).then((value) =>
        value != null
            ? locator<NavigationService>()
                .navigateTo(RouteName.chatBox, arguments: _bookingUserId)
            : null);
  }

  void bookingReject() {
    MoonBlinkRepository.bookingAcceptOrDecline(_userId, _bookingId, BOOKING_REJECT);
  }

  void showBookingDialog() {
    showDialog(
      context: locator<NavigationService>().navigatorKey.currentState.overlay.context,
      builder: (context) => BookingDialog(
          bookingUserName: _bookingUserName,
          gameType: _gameType,
          accept: bookingAccept,
          reject: bookingReject,
      )
    );
  }
}
