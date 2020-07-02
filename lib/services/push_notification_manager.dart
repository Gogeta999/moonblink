import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';

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
      PushNotificationsManager()._showNotification(message);
      print('myBackgroundMessageHandler: $notification');
    }
    return null;
    // Or do other work.
  }

  Future<void> removeFcmToken() async{
    await StorageManager.sharedPreferences.remove(FCMToken);
    await _firebaseMessaging.deleteInstanceID();
    print('${await _firebaseMessaging.getToken()}');
  }

  Future<void> _configLocalNotification() async{
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/moonblink');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _registerNotification() async{
    // For iOS request permission first.
    await _firebaseMessaging.requestNotificationPermissions();
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

    _firebaseMessaging.onTokenRefresh.listen((event) {
      print('onTokenRefresh $event');
      StorageManager.sharedPreferences.setString(FCMToken, event);
    });
  }

  Future<void> _showNotification(message) async {
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
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
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