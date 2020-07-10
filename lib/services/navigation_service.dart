import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/booking/booking_dialog.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
  new GlobalKey<NavigatorState>();

  Future<dynamic> navigateToAndReplace(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState.pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState.pushNamed(routeName, arguments: arguments);
  }

  void showBookingDialog(Function accept, Function decline) {
    showDialog(
      context: navigatorKey.currentState.overlay.context,
      builder: (context) => BookingDialog(accept: accept, decline: decline),
    );
  }

  void goBack() {
    return navigatorKey.currentState.pop();
  }
}