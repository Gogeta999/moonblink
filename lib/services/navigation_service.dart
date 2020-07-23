import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/booking/booking_dialog.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  Future<dynamic> navigateToAndRemoveUntil(String routeName,
      {dynamic arguments}) {
    return navigatorKey.currentState.pushNamedAndRemoveUntil(
        routeName, (route) => false,
        arguments: arguments);
  }

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateToAndReplace(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  void showBookingDialog(
      String bookingUserName, int gameType, Function accept, Function reject) {
    showDialog(
      context: navigatorKey.currentState.overlay.context,
      builder: (context) => BookingDialog(
          bookingUserName: bookingUserName,
          gameType: gameType,
          accept: accept,
          reject: reject),
    );
  }

  void goBack() {
    return navigatorKey.currentState.pop();
  }
}
