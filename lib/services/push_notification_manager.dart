import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moonblink/base_widget/booking/booking_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:oktoast/oktoast.dart';
import 'locator.dart';
import 'navigation_service.dart';

const String FcmTypeMessage = 'message';
const String FcmTypeBooking = 'booking';
const String FcmTypeVoiceCall = 'voice_call';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static PushNotificationsManager _instance = PushNotificationsManager._();

  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      print('FCM initializing');
      await _configLocalNotification();
      await _registerNotification();
      _firebaseMessaging.onTokenRefresh.listen((event) {
        print('onTokenRefresh: $event');
      });
      _initialized = true;
    }
  }

  Future<void> reInit() async {
    if (!_initialized) {
      print('FCM reInit');
      await _registerNotification();
      _initialized = true;
    }
  }

  void dispose() {
    if (_initialized) {
      print('FCM disposing');
      _firebaseMessaging.configure(
        onBackgroundMessage: myBackgroundMessageHandler,
        onMessage: (Map<String, dynamic> message) {
          print(message);
          return;
        },
        onLaunch: (Map<String, dynamic> message) {
          print(message);
          return;
        },
        onResume: (Map<String, dynamic> message) {
          print(message);
          return;
        },
      );
      _initialized = false;
    }
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging()
    ..autoInitEnabled();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final BookingManager _bookingManager = BookingManager();
  final _Message _message = _Message();
  final _VoiceCall _voiceCall = _VoiceCall();

  /*Future<void> removeFcmToken() async {
    //actually it's just storing new fcm token
    await _firebaseMessaging.deleteInstanceID();
    saveFcmToken();
  }*/

  /*Future<void> saveFcmToken() async {
    _firebaseMessaging
        .getToken()
        .then((token) async =>
            await StorageManager.sharedPreferences.setString(FCMToken, token))
        .then((value) =>
            print(StorageManager.sharedPreferences.getString(FCMToken)));
  }*/

  Future<String> getFcmToken() async {
    return _firebaseMessaging.getToken();
  }

  Future<void> _configLocalNotification() async {
    Future<void> onSelectNotification(String payload) async {
      if (payload == FcmTypeBooking) {
        _flutterLocalNotificationsPlugin.cancelAll();
        print('payload: $payload');
        _bookingManager.showBookingDialog();
      } else if (payload == FcmTypeMessage) {
        _flutterLocalNotificationsPlugin.cancelAll();
        print('payload: $payload');
        _message.navigateToChatBox();
      } else if (payload == FcmTypeVoiceCall) {
        _flutterLocalNotificationsPlugin.cancelAll();
        print('payload: $payload');
        _voiceCall.navigateToCallScreen();
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
    //saveFcmToken();
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    print('myBackgroundMessageHandler Executed $message');
    //this only executed when the message is with only data and the app is on background
    //do something
    return;
  }

  Future<dynamic> _onMessage(Map<String, dynamic> message) async {
    //work on foreground and background. on background it automatically show notification
    print('onMessage: $message');
    var fcmType = message['data']['fcm_type'] ?? message['fcm_type'];
    if (fcmType == FcmTypeBooking) {
      _showBookingNotification(message);
    } else if (fcmType == FcmTypeMessage) {
      _showMessageNotification(message);
    } else if (fcmType == FcmTypeVoiceCall) {
      _showVoiceCallNotification(message);
    }
    showToast('onMessage');
    return;
  }

  Future<dynamic> _onResume(Map<String, dynamic> message) async {
    //on background and click it
    print('onResume: $message');
    showToast('onResume');
    var fcmType = message['data']['fcm_type'] ?? message['fcm_type'];
    if (fcmType == FcmTypeBooking) {
      _showBookingDialog(message);
    } else if (fcmType == FcmTypeMessage) {
      final int partnerId =
          json.decode(message['data']['sender_id'] ?? message['sender_id']);
      _message.prepare(partnerId: partnerId);
      _message.navigateToChatBox();
    } else if (fcmType == FcmTypeVoiceCall) {
      final String callChannel =
          message['data']['call_channel'] ?? message['call_channel'];
      _voiceCall.prepare(callChannel: callChannel);
      _voiceCall.navigateToCallScreen();
    }
    return;
  }

  Future<dynamic> _onLaunch(Map<String, dynamic> message) async {
    //onTerminated
    print('onLaunch: $message');
    var fcmType = message['data']['fcm_type'] ?? message['fcm_type'];
    locator<NavigationService>().navigateToAndReplace(RouteName.main);
    showToast('onLaunch');
    if (fcmType == FcmTypeBooking) {
      _showBookingDialog(message);
    } else if (fcmType == FcmTypeMessage) {
      final int partnerId =
          json.decode(message['data']['sender_id'] ?? message['sender_id']);
      _message.prepare(partnerId: partnerId);
      _message.navigateToChatBox();
    } else if (fcmType == FcmTypeVoiceCall) {
      final String callChannel =
          message['data']['call_channel'] ?? message['call_channel'];
      _voiceCall.prepare(callChannel: callChannel);
      _voiceCall.navigateToCallScreen();
    }
  }

  _showBookingDialog(message) async {
    final int userId =
        json.decode(message['data']['user_id'] ?? message['user_id']);
    final int bookingId = json.decode(message['data']['id'] ?? message['id']);
    final int bookingUserId = json.decode(
        message['data']['booking_user_id'] ?? message['booking_user_id']);
    final int gameType =
        json.decode(message['data']['game_type'] ?? message['game_type']);
    final String bookingUserName = message['data']['name'] ?? message['name'];
    print(
        'userId: $userId, bookingId: $bookingId, bookingUserId: $bookingUserId, gameType: $gameType');
    _bookingManager.bookingPrepare(
      bookingUserName: bookingUserName,
      gameType: gameType,
      userId: userId,
      bookingId: bookingId,
      bookingUserId: bookingUserId,
    );
    _bookingManager.showBookingDialog();
  }

  //For booking Fcm
  Future<void> _showBookingNotification(message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.moonuniverse.moonblink.booking', //same package name for both platform
      'Moon Blink',
      'Moon Blink',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    final int userId =
        json.decode(message['data']['user_id'] ?? message['user_id']);
    final int bookingId = json.decode(message['data']['id'] ?? message['id']);
    final int bookingUserId = json.decode(
        message['data']['booking_user_id'] ?? message['booking_user_id']);
    final int gameType =
        json.decode(message['data']['game_type'] ?? message['game_type']);
    final String bookingUserName = message['data']['name'] ?? message['name'];
    print(
        'userId: $userId, bookingId: $bookingId, bookingUserId: $bookingUserId, gameTpye: $gameType');

    _bookingManager.bookingPrepare(
      bookingUserName: bookingUserName,
      gameType: gameType,
      userId: userId,
      bookingId: bookingId,
      bookingUserId: bookingUserId,
    );

    await _flutterLocalNotificationsPlugin.show(
        0,
        message['notification']['title'].toString(),
        message['notification']['body'].toString(),
        platformChannelSpecifics,
        payload: message['data']['fcm_type'] ?? message['fcm_type']);
  }

  //For message Fcm
  Future<void> _showMessageNotification(message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.moonuniverse.moonblink', //same package name for both platform
      'Moon Blink',
      'Moon Blink',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    final int partnerId =
        json.decode(message['data']['sender_id'] ?? message['sender_id']);

    _message.prepare(partnerId: partnerId);

    await _flutterLocalNotificationsPlugin.show(
        0,
        message['notification']['title'].toString(),
        message['notification']['body'].toString(),
        platformChannelSpecifics,
        payload: message['data']['fcm_type'] ?? message['fcm_type']);
  }

  Future<void> _showVoiceCallNotification(message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.moonuniverse.moonblink', //same package name for both platform
      'Moon Blink',
      'Moon Blink',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/moonblink'),
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    final String callChannel =
        message['data']['call_channel'] ?? message['call_channel'];

    _voiceCall.prepare(callChannel: callChannel);

    await _flutterLocalNotificationsPlugin.show(
        0,
        message['notification']['title'].toString(),
        message['notification']['body'].toString(),
        platformChannelSpecifics,
        payload: message['data']['fcm_type'] ?? message['fcm_type']);
  }

  //local voice call notification
  Future<void> showVoiceCallNotification(String channelName) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.moonuniverse.moonblink', //same package name for both platform
        channelName,
        'Moon Blink',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/moonblink'),
        playSound: true,
        enableVibration: true,
        importance: Importance.Max,
        priority: Priority.High,
        ongoing: true,
        autoCancel: false);

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
        1, 'Voice Call', 'Calling', platformChannelSpecifics);
  }

  Future<void> cancelVoiceCallNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(1);
  }
}

class _Message {
  int _partnerId;

  void prepare({int partnerId}) {
    this._partnerId = partnerId;
  }

  void navigateToChatBox() {
    locator<NavigationService>()
        .navigateTo(RouteName.chatBox, arguments: _partnerId);
  }
}

//call_channel
class _VoiceCall {
  String _callChannel;

  void prepare({String callChannel}) {
    this._callChannel = callChannel;
  }

  void navigateToCallScreen() {
    locator<NavigationService>()
        .navigateTo(RouteName.callScreen, arguments: _callChannel);
  }
}
