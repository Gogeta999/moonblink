import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moonblink/base_widget/booking/booking_manager.dart';
import 'package:moonblink/base_widget/update_profile_dialog.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/main.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'locator.dart';
import 'navigation_service.dart';

const String FcmTypeMessage = 'message';
const String FcmTypeBooking = 'booking';
const String FcmTypeVoiceCall = 'voice_call';
const String FcmTypeGameIdUpdate = 'game_id_update';

class PushNotificationsManager {
  PushNotificationsManager._();
  // AndroidNotificationChannel
  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      print('FCM initializing');
      await _configLocalNotification();
      // For iOS request permission first.
      await _firebaseMessaging.requestNotificationPermissions();
      usertoken != null ? _registerNotification() : _unregisterNotification();
      _firebaseMessaging.onTokenRefresh.listen((event) {
        print('onTokenRefresh: $event');
      });
      print('FCM_Token: ${await getFcmToken()}');
      _createLocalNotiChannel('moon_go_noti', 'moon_go_noti', 'For Server FCM');
      _initialized = true;
    }
  }

  Future<void> reInit() async {
    if (!_initialized) {
      print('FCM reInit');
      _registerNotification();
      _initialized = true;
    }
  }

  void dispose() {
    if (_initialized) {
      print('FCM disposing');
      _unregisterNotification();
      _initialized = false;
    }
  }

  Future<void> _createLocalNotiChannel(
      String id, String name, String description) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidNotificationChannel = AndroidNotificationChannel(
      id,
      name,
      description,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging()
    ..autoInitEnabled();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final BookingManager _bookingManager = BookingManager();
  final _Message _message = _Message();
  final _VoiceCall _voiceCall = _VoiceCall();
  final _UpdateProfile _updateProfile = _UpdateProfile();

  Future<String> getFcmToken() async {
    return _firebaseMessaging.getToken();
  }

  Future<void> _configLocalNotification() async {
    ///android
    Future<void> onSelectNotification(String payload) async {
      if (payload == FcmTypeBooking) {
        print('payload: $payload');
        _bookingManager.showBookingDialog();
      } else if (payload == FcmTypeMessage) {
        print('payload: $payload');
        _message.navigateToChatBox();
      } else if (payload == FcmTypeVoiceCall) {
        print('payload: $payload');
        _voiceCall.navigateToCallScreen();
      }
    }

    ///iOS
    Future<dynamic> onDidReceiveLocalNotification(
        int id, String title, String body, String payload) async {
      if (payload == FcmTypeBooking) {
        print('payload: $payload');
        _bookingManager.showBookingDialog();
      } else if (payload == FcmTypeMessage) {
        print('payload: $payload');
        _message.navigateToChatBox();
      } else if (payload == FcmTypeVoiceCall) {
        print('payload: $payload');
        _voiceCall.navigateToCallScreen();
      }
    }

    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void _registerNotification() {
    _firebaseMessaging.configure(
        onMessage: _onMessage,
        onBackgroundMessage: myBackgroundMessageHandler,
        onResume: _onResume,
        onLaunch: _onLaunch);
    //saveFcmToken();
  }

  void _unregisterNotification() {
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
    var fcmType =
        Platform.isAndroid ? message['data']['fcm_type'] : message['fcm_type'];
    if (fcmType == FcmTypeBooking) {
      _showBookingNotification(message);
    } else if (fcmType == FcmTypeMessage) {
      _showMessageNotification(message);
    } else if (fcmType == FcmTypeVoiceCall) {
      _showVoiceCallNotification(message);
    } else if (fcmType == FcmTypeGameIdUpdate) {
      _showGameIdUpdateDialog(message);
    }
    return;
  }

  Future<dynamic> _onResume(Map<String, dynamic> message) async {
    //on background and click it
    print('onResume: $message');
    var fcmType =
        Platform.isAndroid ? message['data']['fcm_type'] : message['fcm_type'];
    if (fcmType == FcmTypeBooking) {
      _showBookingDialog(message);
    } else if (fcmType == FcmTypeMessage) {
      int partnerId = Platform.isAndroid
          ? json.decode(message['data']['sender_id'])
          : json.decode(message['sender_id']);
      _message.prepare(partnerId: partnerId);
      _message.navigateToChatBox();
    } else if (fcmType == FcmTypeVoiceCall) {
      String callChannel = Platform.isAndroid
          ? message['data']['call_channel']
          : message['call_channel'];
      _voiceCall.prepare(callChannel: callChannel);
      _voiceCall.navigateToCallScreen();
    }
    return;
  }

  Future<dynamic> _onLaunch(Map<String, dynamic> message) async {
    //onTerminated
    print('onLaunch: $message');
    var fcmType =
        Platform.isAndroid ? message['data']['fcm_type'] : message['fcm_type'];
    locator<NavigationService>().navigateToAndReplace(RouteName.main);
    if (fcmType == FcmTypeBooking) {
      _showBookingDialog(message);
    } else if (fcmType == FcmTypeMessage) {
      int partnerId = Platform.isAndroid
          ? json.decode(message['data']['sender_id'])
          : json.decode(message['sender_id']);
      _message.prepare(partnerId: partnerId);
      _message.navigateToChatBox();
    } else if (fcmType == FcmTypeVoiceCall) {
      String callChannel = Platform.isAndroid
          ? message['data']['call_channel']
          : message['call_channel'];
      _voiceCall.prepare(callChannel: callChannel);
      _voiceCall.navigateToCallScreen();
    }
  }

  _showGameIdUpdateDialog(message) async {
    String name = '';
    String profileImage = '';
    String coverImage = '';
    String bios = '';

    if (Platform.isAndroid) {
      name = message['data']['name'];
      profileImage = message['data']['profile_image'];
      coverImage = message['data']['cover_image'];
      bios = message['data']['bios'];
    } else if (Platform.isIOS) {
      name = message['name'];
      profileImage = message['profile_image'];
      coverImage = message['cover_image'];
      bios = message['bios'];
    } else {
      showToast('This platform is not supported');
      return;
    }

    print(name);

    final PartnerProfile  partnerProfile = PartnerProfile(
      profileImage: profileImage, coverImage: coverImage,
      bios: bios,
    );

    final PartnerUser partnerUser = PartnerUser(
      partnerName: name, prfoileFromPartner: partnerProfile
    );

    _updateProfile.prepare(partnerUser: partnerUser);

    _updateProfile.showUpdateProfileDialog();
  }

  _showBookingDialog(message) async {
    int userId = 0;
    int bookingId = 0;
    int bookingUserId = 0;
    int gameType = 0;
    String bookingUserName = '';

    if (Platform.isAndroid) {
      userId = json.decode(message['data']['user_id']);
      bookingId = json.decode(message['data']['id']);
      bookingUserId = json.decode(message['data']['booking_user_id']);
      gameType = json.decode(message['data']['game_type']);
      bookingUserName = message['data']['name'];
    } else if (Platform.isIOS) {
      userId = json.decode(message['user_id']);
      bookingId = json.decode(message['id']);
      bookingUserId = json.decode(message['booking_user_id']);
      gameType = json.decode(message['game_type']);
      bookingUserName = message['name'];
    } else {
      showToast('This platform is not supported');
      return;
    }

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
    NotificationDetails platformChannelSpecifics =
        setUpPlatformSpecifics('booking', 'Booking', song: 'moonblink_noti');
    int userId = 0;
    int bookingId = 0;
    int bookingUserId = 0;
    int gameType = 0;
    String bookingUserName = '';

    String title = '';
    String body = '';

    String payload = '';

    if (Platform.isAndroid) {
      userId = json.decode(message['data']['user_id']);
      bookingId = json.decode(message['data']['id']);
      bookingUserId = json.decode(message['data']['booking_user_id']);
      gameType = json.decode(message['data']['game_type']);
      bookingUserName = message['data']['name'];

      title = message['notification']['title'].toString();
      body = message['notification']['body'].toString();
      payload = message['data']['fcm_type'];
    } else if (Platform.isIOS) {
      userId = json.decode(message['user_id']);
      bookingId = json.decode(message['id']);
      bookingUserId = json.decode(message['booking_user_id']);
      gameType = json.decode(message['game_type']);
      bookingUserName = message['name'];

      title = message['aps']['alert']['title'].toString();
      body = message['aps']['alert']['body'].toString();
      payload = message['fcm_type'];
    } else {
      showToast('This platform is not supported');
      return;
    }

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
        0, title.toString(), body.toString(), platformChannelSpecifics,
        payload: payload);
  }

  //For message Fcm
  Future<void> _showMessageNotification(message) async {
    bool atChatBox = StorageManager.sharedPreferences.get(isUserAtChatBox);
    if (!atChatBox) {
      NotificationDetails platformChannelSpecifics =
          setUpPlatformSpecifics('message', 'Messaging', song: null);
      int partnerId = 0;
      String title = '';
      String body = '';
      String payload = '';

      if (Platform.isAndroid) {
        partnerId = json.decode(message['data']['sender_id']);
        title = message['notification']['title'].toString();
        body = message['notification']['body'].toString();
        payload = message['data']['fcm_type'];
      } else if (Platform.isIOS) {
        partnerId = json.decode(message['sender_id']);
        title = message['aps']['alert']['title'].toString();
        body = message['aps']['alert']['body'].toString();
        payload = message['fcm_type'];
      } else {
        showToast('This platform is not supported');
        return;
      }

      _message.prepare(partnerId: partnerId);

      await _flutterLocalNotificationsPlugin
          .show(0, title, body, platformChannelSpecifics, payload: payload);
    }
  }

  Future<void> _showVoiceCallNotification(message) async {
    NotificationDetails platformChannelSpecifics =
        setUpPlatformSpecifics('voicecall', 'Voice Call', song: null);

    String callChannel = '';
    String title = '';
    String body = '';
    String payload = '';

    if (Platform.isAndroid) {
      callChannel = message['data']['call_channel'];
      title = message['notification']['title'].toString();
      body = message['notification']['body'].toString();
      payload = message['data']['fcm_type'];
    } else if (Platform.isIOS) {
      callChannel = message['call_channel'];
      title = message['aps']['alert']['title'].toString();
      body = message['aps']['alert']['body'].toString();
      payload = message['fcm_type'];
    } else {
      showToast('This platform is not supported');
      return;
    }

    _voiceCall.prepare(callChannel: callChannel);

    await _flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: payload);
  }

  //local voice call notification
  Future<void> showVoiceCallNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.moonuniverse.moonblink', //same package name for both platform
        'Moon Blink Voice Call',
        'Moon Blink',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/moonblink'),
        playSound: true,
        importance: Importance.Max,
        priority: Priority.High,
        ongoing: true,
        sound: RawResourceAndroidNotificationSound('moonblink_noti'),
        autoCancel: false);

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
        1, 'Voice Call', 'Calling', platformChannelSpecifics);
  }

  NotificationDetails setUpPlatformSpecifics(name, channelName, {String song}) {
    if (song != null) {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.moonuniverse.moonblink.$name', //same package name for both platform
        'Moon Blink $channelName',
        'Moon Blink',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('$song'),
        enableVibration: true,
        importance: Importance.Max,
        priority: Priority.High,
      );
      var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true,
        sound: 'moonblink_noti.m4r'
      );
      var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      return platformChannelSpecifics;
    } else {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.moonuniverse.moonblink.$name', //same package name for both platform
        'Moon Blink $channelName',
        'Moon Blink',
        playSound: true,

        enableVibration: true,
        importance: Importance.Max,
        priority: Priority.High,
      );
      var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true,
      );
      var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      return platformChannelSpecifics;
    }
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
    bool atChatBox = StorageManager.sharedPreferences.get(isUserAtChatBox);
    if (!atChatBox)
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
    bool atVoiceCallPage =
        StorageManager.sharedPreferences.get(isUserAtVoiceCallPage);
    if (!atVoiceCallPage)
      locator<NavigationService>()
          .navigateTo(RouteName.callScreen, arguments: _callChannel);
  }
}

class _UpdateProfile {
  PartnerUser partnerUser;

  void prepare({PartnerUser partnerUser}) {
    this.partnerUser = partnerUser;
  }

  void navigateToUpdateProfile() {
    locator<NavigationService>()
        .navigateTo(RouteName.updateprofile, arguments: partnerUser);
  }

  void showUpdateProfileDialog() {
    showDialog(
        context: locator<NavigationService>().navigatorKey.currentState.overlay.context,
        builder: (context) => UpdateProfileDialog(
          partnerUser: this.partnerUser,
          navigateToProfilePage: () => this.navigateToUpdateProfile(),
        )
    );
  }
}