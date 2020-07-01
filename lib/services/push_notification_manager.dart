import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moonblink/utils/platform_utils.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static Future<dynamic> _myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      print(data);
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      print(notification);
    }
    return null;
    // Or do other work.
  }

  void _configLocalNotification() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _registerNotification() {
    // For iOS request permission first.
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) {
          print('onMessage: $message');
          Platform.isAndroid
              ? _showNotification(message['notification'])
              : _showNotification(message['aps']['alert']);
          return;
        },
        onBackgroundMessage: _myBackgroundMessageHandler,
        onResume: (Map<String, dynamic> message) {
          print('onResumse: $message');
          return;
        },
        onLaunch: (Map<String, dynamic> message) {
          print('onLaunch: $message');
          return;
        });

    _firebaseMessaging.getToken().then((token) {
      print('token: $token');
      //send token to backend
    });
  }

  void _showNotification(message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.moonuniverse.moonblink', //same package name for both platform
      'Moon Blink',
      'Flutter Blink',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  Future<void> init() async {
    if (!_initialized) {
      _configLocalNotification();
      _registerNotification();
      _initialized = true;
    }
  }
}
