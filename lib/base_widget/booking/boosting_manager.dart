import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/booking/boosting_dialog.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:moonblink/utils/constants.dart';

class BoostingManager {
  int _userId;
  int _bookingId;
  int _bookingUserId;
  String _bookingUserName;
  String _gameName;
  int _estimateCost = 0;
  int _estimateDay = 0;
  int _estimateHour = 0;
  String _rankFrom = '';
  String _upToRank = '';

  void boostingPrepare(
      int userId,
      int bookingId,
      int bookingUserId,
      String bookingUserName,
      String gameName,
      int estimateCost,
      int estimateDay,
      int estimateHour,
      String rankFrom,
      String upToRank) {
    this._userId = userId;
    this._bookingId = bookingId;
    this._bookingUserId = bookingUserId;
    this._bookingUserName = bookingUserName;
    this._gameName = gameName;
    this._estimateCost = estimateCost;
    this._estimateDay = estimateDay;
    this._estimateHour = estimateHour;
    this._rankFrom = rankFrom;
    this._upToRank = upToRank;
  }

  void boostingAccept() {
    MoonBlinkRepository.setBoostingStatus(_bookingId, BOOST_ACCEPTED).then(
        (value) => value != null
            ? () {
              bool atChatBox = StorageManager.sharedPreferences.getBool(isUserAtChatBox);
              if (!atChatBox)
                locator<NavigationService>()
                .navigateTo(RouteName.chatBox, arguments: _bookingUserId);
            }
            : null);
  }

  void boostingReject() {
    MoonBlinkRepository.setBoostingStatus(_bookingId, BOOST_REJECT);
  }

  void showBoostingDialog() {
    showDialog(
        context: locator<NavigationService>()
            .navigatorKey
            .currentState
            .overlay
            .context,
        builder: (context) => BoostingDialog(
            _userId,
            _bookingId,
            _bookingUserId,
            _bookingUserName,
            _gameName,
            _estimateCost,
            _estimateDay,
            _estimateHour,
            _rankFrom,
            _upToRank,
            boostingAccept,
            boostingReject));
  }
}
