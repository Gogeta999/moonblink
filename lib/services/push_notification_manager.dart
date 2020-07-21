import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moonblink/base_widget/booking/booking_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'locator.dart';
import 'navigation_service.dart';

const String FcmTypeMessage = 'message';
const String FcmTypeBooking = 'booking';
const String FcmTypeVoiceCall = 'voice_call';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final BookingManager _bookingManager = BookingManager();
  final _Message _message = _Message();

  bool _initialized = false;

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
      if (payload == FcmTypeBooking) {
        _flutterLocalNotificationsPlugin.cancelAll();
        print('payload: $payload');
        locator<NavigationService>().showBookingDialog(
            () => _bookingManager.bookingAccept(),
            () => _bookingManager.bookingReject());
      }else if(payload == FcmTypeMessage){
       _flutterLocalNotificationsPlugin.cancelAll();
       print('payload: $payload');
       _message.navigateToChatBox();
       //don't trigger message notification for now
       //locator<NavigationService>().navigateTo(RouteName.chatBox, arguments: 6);
    } else {
        _flutterLocalNotificationsPlugin.cancelAll();
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
        onMessage: _onMessage,
        onBackgroundMessage: myBackgroundMessageHandler,
        onResume: _onResume,
        onLaunch: _onLaunch);
    saveFcmToken();
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    print('myBackgroundMessageHandler Executed $message');
    //this only executed when the message is with only data and the app is on background
    //do something
    return null;
  }

  Future<dynamic> _onMessage(Map<String, dynamic> message) async {
    //work on foreground and background. on background it automatically show notification
    print('onMessage: $message');
    var fcmType = message['data']['fcm_type'] ?? message['fcm_type'];
    if(fcmType == FcmTypeBooking){
      _showBookingNotification(message);
    }else if(fcmType == FcmTypeMessage){
      _showMessageNotification(message);
    }
    showToast('onMessage');
    return null;
  }

  Future<dynamic> _onResume(Map<String, dynamic> message) async {
    //on background and click it
    print('onResume: $message');
    showToast('onResume');
    var fcmType = message['data']['fcm_type'] ?? message['fcm_type'];
    if(fcmType == FcmTypeBooking){
      _showBookingDialog(message);
    } else if(fcmType == FcmTypeMessage){
      final int partnerId = json.decode(message['data']['sender_id'] ?? message['sender_id']);
      locator<NavigationService>().navigateTo(RouteName.chatBox, arguments: partnerId);
    }
    return null;
  }

  Future<dynamic> _onLaunch(Map<String, dynamic> message) async {
    //onTerminated
    print('onLaunch: $message');
    var fcmType = message['data']['fcm_type'] ?? message['fcm_type'];
    locator<NavigationService>().navigateToAndReplace(RouteName.main);
    if(fcmType == FcmTypeBooking){
      _showBookingDialog(message);
    } else if(fcmType == FcmTypeMessage){
      final int partnerId = json.decode(message['data']['sender_id'] ?? message['sender_id']);
      locator<NavigationService>().navigateTo(RouteName.chatBox, arguments: partnerId);
    }
    return null;
  }

  _showBookingDialog(message) async{
    final int userId = json.decode(message['data']['user_id'] ?? message['user_id']);
    final int bookingId = json.decode(message['data']['id'] ?? message['id']);
    final int bookingUserId =
    json.decode(message['data']['booking_user_id'] ?? message['booking_user_id']);
    print(
        'userId: $userId, bookingId: $bookingId, bookingUserId: $bookingUserId');
    _bookingManager.bookingPrepare(
        userId: userId,
        bookingId: bookingId,
        bookingUserId: bookingUserId);
    locator<NavigationService>().showBookingDialog(
            () => _bookingManager.bookingAccept(),
            () => _bookingManager.bookingReject());
  }

  //For booking Fcm
  Future<void> _showBookingNotification(message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.moonuniverse.moonblink', //same package name for both platform
      'Moon Blink',
      'Flutter Blink',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
      ongoing: true,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);
    print(message['data']);
    print(json.decode(message['data']['booking_user_id']));

    final int userId = json.decode(message['data']['user_id'] ?? message['user_id']);
    final int bookingId = json.decode(message['data']['id'] ?? message['id']);
    final int bookingUserId = json.decode(message['data']['booking_user_id'] ?? message['booking_user_id']);
    print(
        'userId: $userId, bookingId: $bookingId, bookingUserId: $bookingUserId');
    _bookingManager.bookingPrepare(
        userId: userId, bookingId: bookingId, bookingUserId: bookingUserId);

    await _flutterLocalNotificationsPlugin.show(0, message['notification']['title'].toString(),
        message['notification']['body'].toString(), platformChannelSpecifics,
        payload: message['data']['fcm_type']);
  }

  //For message Fcm
  Future<void> _showMessageNotification(message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.moonuniverse.moonblink', //same package name for both platform
      'Moon Blink',
      'Flutter Blink',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
      ongoing: true,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    final int partnerId = json.decode(message['data']['sender_id'] ?? message['sender_id']);

    _message.prepare(partnerId: partnerId);

    await _flutterLocalNotificationsPlugin.show(0, message['notification']['title'].toString(),
        message['notification']['body'].toString(), platformChannelSpecifics,
        payload: message['data']['fcm_type']);
  }

  Future<void> showVoiceCallNotification(String channelName, String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.moonuniverse.moonblink', //same package name for both platform
      channelName,
      'Moon Blink',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/moonblink'),
      importance: Importance.Max,
      priority: Priority.High,
      ongoing: true,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(0, title,
        body, platformChannelSpecifics, payload: null);
  }

  //chatting notification
  Future<void> notification(int id, String user, String message) async {
    print("showing noti");
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('ChannelID', 'Channel title', 'channel body',
            priority: Priority.High,
            importance: Importance.Max,
            autoCancel: false,
            ongoing: true,
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

class _Message {
  int partnerId;

  void prepare({int partnerId}) {
    this.partnerId = partnerId;
  }

  void navigateToChatBox() {
    locator<NavigationService>().navigateTo(RouteName.chatBox, arguments: partnerId);
  }
}