import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moonblink/base_widget/booking/booking_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';

import 'locator.dart';
import 'navigation_service.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final BookingManager _bookingManager = BookingManager();

  bool _initialized = false;

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    print('myBackgroundMessageHandler Executed Thanks God');
    PushNotificationsManager()
        ._showNotification(message['notification'], message['data']);
    return null;
  }

  Future<void> removeFcmToken() async {
    //actually it's just storing new fcm token
    await _firebaseMessaging.deleteInstanceID();
    saveFcmToken();
  }

  Future<void> saveFcmToken() async {
    _firebaseMessaging
        .getToken()
        .then((token) async =>
            await StorageManager.sharedPreferences.setString(FCMToken, token))
        .then((value) =>
            print(StorageManager.sharedPreferences.getString(FCMToken)));
  }

  Future<void> _configLocalNotification() async {
    Future<void> onSelectNotification(String payload) async {
      if (payload != null) {
        print('payload: $payload');
        locator<NavigationService>().showBookingDialog(
            () => _bookingManager.bookingAccept(),
            () => _bookingManager.bookingReject());
      }
    }

    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> _registerNotification() async {
    // For iOS request permission first.
    await _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) {
          print('onMessage: $message');
          Platform.isAndroid
              ? _showNotification(message['notification'], message['data'])
              : _showNotification(message['aps']['alert'], null);
          return;
        },
        onBackgroundMessage: myBackgroundMessageHandler,
        onResume: (Map<String, dynamic> message) {
          print('onResume: $message');
          final int userId = json.decode(message['data']['user_id']);
          final int bookingId = json.decode(message['data']['id']);
          final int bookingUserId =
              json.decode(message['data']['booking_user_id']);
          print(
              'userId: $userId, bookingId: $bookingId, bookingUserId: $bookingUserId');
          _bookingManager.bookingPrepare(
              userId: userId,
              bookingId: bookingId,
              bookingUserId: bookingUserId);
          locator<NavigationService>().showBookingDialog(
              () => _bookingManager.bookingAccept(),
              () => _bookingManager.bookingReject());
          return;
        },
        onLaunch: (Map<String, dynamic> message) {
          print('onLaunch: $message');
          return;
        });
    saveFcmToken();
  }

  Future<void> _showNotification(message, data) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.moonuniverse.moonblink', //same package name for both platform
      'Moon Blink',
      'Flutter Blink',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);
    print(data);
    print(json.decode(data['booking_user_id']));

    final int userId = json.decode(data['user_id']);
    final int bookingId = json.decode(data['id']);
    final int bookingUserId = json.decode(data['booking_user_id']);
    print(
        'userId: $userId, bookingId: $bookingId, bookingUserId: $bookingUserId');
    _bookingManager.bookingPrepare(
        userId: userId, bookingId: bookingId, bookingUserId: bookingUserId);

    await _flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: bookingUserId.toString());
  }

  //chatting notification
  Future<void> notification(int id, String user, String message) async {
    print("showing noti");
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('ChannelID', 'Channel title', 'channel body',
            priority: Priority.High,
            importance: Importance.Max,
            autoCancel: false,
            // ongoing: true,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await _flutterLocalNotificationsPlugin.show(
        id, user, message, notificationDetails);
  }

  Future<void> init() async {
    if (!_initialized) {
      print('FCM initializing');
      await _configLocalNotification();
      await _registerNotification();
      _initialized = true;
    }
  }
}
