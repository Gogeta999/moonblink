import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moonblink/global/router_manager.dart';
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

  bool _initialized = false;

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {

    if (message.containsKey('notification')) {
      //PushNotificationsManager()._showNotification(message['notification'], message['data']);
    }
    
    if(message != null) {
      PushNotificationsManager()._showNotification(message['notification'], message['data']);
    }
    return null;
    // Or do other work.
  }

  Future<void> removeFcmToken() async {
    //await StorageManager.sharedPreferences.remove(FCMToken);
    //actually storing new fcm token
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
      if(payload != null){
        final chatId = int.tryParse(payload);
        await locator<NavigationService>()
            .navigateTo(RouteName.chatBox, arguments: chatId);
      }
    }

    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/moonblink');
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
          ///onResume need 'click_action: FLUTTER_NOTIFICATION_CLICK' on data
          ///if id from json type is Int
          final chatIdFromInt = json.decode(message['data']['booking_user_id']);
          ///if id from json type is String
          //final chatIdFromString = int.tryParse(json.decode(message['data']['booking_user_id']));
          locator<NavigationService>()
              .navigateTo(RouteName.chatBox, arguments: chatIdFromInt);
          return;
        },
        onLaunch: (Map<String, dynamic> message) {
          print('onLaunch: $message');
          return;
        });
    //testing
    _firebaseMessaging.onTokenRefresh.listen((event) async {
      print('onTokenRefresh $event');
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
    await _flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.decode(data['booking_user_id']));
  }

  //chatting notification
  Future<void> notification(int id,String user, String message) async {
    print("showing noti");
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        'ChannelID', 'Channel title', 'channel body',
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
