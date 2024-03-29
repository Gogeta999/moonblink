import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/booking/booking_manager.dart';
import 'package:moonblink/base_widget/booking/boosting_manager.dart';
import 'package:moonblink/base_widget/update_profile_dialog.dart';
import 'package:moonblink/bloc_pattern/user_notification/new/user_new_notification_bloc.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'locator.dart';
import 'navigation_service.dart';

const String FcmTypeMessage = 'message';
const String FcmTypeBooking = 'booking';
const String FcmTypeBoosting = 'boosting';
const String FcmTypeVoiceCall = 'voice_call';
const String FcmTypeGameIdUpdate = 'game_id_update';
const String GameProfileAdd = 'gameprofileadd';

class PushNotificationsManager {
  String usertoken = StorageManager.sharedPreferences.getString(token);
  PushNotificationsManager._();
  // AndroidNotificationChannel
  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      if (isDev) print('FCM initializing');
      await _configLocalNotification();
      // For iOS request permission first.
      await _firebaseMessaging.requestNotificationPermissions();
      usertoken != null ? _registerNotification() : _unregisterNotification();
      _firebaseMessaging.onTokenRefresh.listen((event) {
        if (isDev) print('onTokenRefresh: $event');
      });
      if (isDev) print('FCM_Token: ${await getFcmToken()}');
      _initialized = true;
    }
  }

  Future<void> reInit() async {
    if (!_initialized) {
      _registerNotification();
      _initialized = true;
    }
  }

  void dispose() {
    if (_initialized) {
      _unregisterNotification();
      _initialized = false;
    }
  }

  // Future<void> _createLocalNotiChannel(
  //     String id, String name, String description) async {
  //   final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //   var androidNotificationChannel = AndroidNotificationChannel(
  //     id,
  //     name,
  //     description,
  //   );
  //   await flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //           AndroidFlutterLocalNotificationsPlugin>()
  //       ?.createNotificationChannel(androidNotificationChannel);
  // }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging()
    ..autoInitEnabled();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final BookingManager _bookingManager = BookingManager();
  final BoostingManager _boostingManager = BoostingManager();
  final _Message _message = _Message();
  final _VoiceCall _voiceCall = _VoiceCall();
  final _UpdateProfile _updateProfile = _UpdateProfile();

  Future<String> getFcmToken() async {
    return _firebaseMessaging.getToken();
  }

  Future<void> _configLocalNotification() async {
    ///android
    Future<void> onSelectNotification(String payload) async {
      if (StorageManager.sharedPreferences.get(isUserOnForeground)) {
        if (payload == FcmTypeBooking) {
          _bookingManager.showBookingDialog();
        } else if (payload == FcmTypeBoosting) {
          _boostingManager.showBoostingDialog();
        } else if (payload == FcmTypeMessage) {
          _message.navigateToChatBox();
        } else if (payload == FcmTypeVoiceCall) {
          _voiceCall.navigateToCallScreen();
        } else if (payload == GameProfileAdd) {
          navigatotogameprofile();
        }
      } else {
        locator<NavigationService>().navigateToAndReplace(RouteName.main);
        if (payload == FcmTypeBooking) {
          _bookingManager.showBookingDialog();
        } else if (payload == FcmTypeBoosting) {
          _boostingManager.showBoostingDialog();
        } else if (payload == FcmTypeMessage) {
          _message.navigateToChatBox();
        } else if (payload == FcmTypeVoiceCall) {
          _voiceCall.navigateToCallScreen();
        } else if (payload == GameProfileAdd) {
          navigatotogameprofile();
        }
      }
    }

    ///iOS
    Future<dynamic> onDidReceiveLocalNotification(
        int id, String title, String body, String payload) async {
      if (StorageManager.sharedPreferences.get(isUserOnForeground)) {
        if (payload == FcmTypeBooking) {
          _bookingManager.showBookingDialog();
        } else if (payload == FcmTypeBoosting) {
          _boostingManager.showBoostingDialog();
        } else if (payload == FcmTypeMessage) {
          _message.navigateToChatBox();
        } else if (payload == FcmTypeVoiceCall) {
          _voiceCall.navigateToCallScreen();
        } else if (payload == GameProfileAdd) {
          navigatotogameprofile();
        }
      } else {
        locator<NavigationService>().navigateToAndReplace(RouteName.main);
        if (payload == FcmTypeBooking) {
          _bookingManager.showBookingDialog();
        } else if (payload == FcmTypeBoosting) {
          _boostingManager.showBoostingDialog();
        } else if (payload == FcmTypeMessage) {
          _message.navigateToChatBox();
        } else if (payload == FcmTypeVoiceCall) {
          _voiceCall.navigateToCallScreen();
        } else if (payload == GameProfileAdd) {
          navigatotogameprofile();
        }
      }
    }

    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
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
        return;
      },
      onLaunch: (Map<String, dynamic> message) {
        return;
      },
      onResume: (Map<String, dynamic> message) {

        return;
      },
    );
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    //this only executed when the message is with only data and the app is on background
    //do something
    return;
  }

  Future<dynamic> _onMessage(Map<String, dynamic> message) async {
    //work on foreground and background. on background it automatically show notification
    if (isDev) print('onMessage: $message');
    var fcmType =
        Platform.isAndroid ? message['data']['fcm_type'] : message['fcm_type'];
    if (fcmType == FcmTypeBooking) {
      _showBookingNotification(message);
    } else if (fcmType == FcmTypeBoosting) {
      _showBoostingNotification(message);
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
    if (isDev) print('onResume: $message');
    var fcmType =
        Platform.isAndroid ? message['data']['fcm_type'] : message['fcm_type'];
    if (fcmType == FcmTypeBooking) {
      _showBookingDialog(message);
    } else if (fcmType == FcmTypeBoosting) {
      _showBoostingDialog(message);
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
    if (isDev) print('onLaunch: $message');
    var fcmType =
        Platform.isAndroid ? message['data']['fcm_type'] : message['fcm_type'];
    locator<NavigationService>().navigateToAndReplace(RouteName.main);
    if (fcmType == FcmTypeBooking) {
      _showBookingDialog(message);
    } else if (fcmType == FcmTypeBoosting) {
      _showBoostingDialog(message);
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

    final PartnerProfile partnerProfile = PartnerProfile(
      profileImage: profileImage,
      coverImage: coverImage,
      bios: bios,
    );

    final PartnerUser partnerUser =
        PartnerUser(partnerName: name, prfoileFromPartner: partnerProfile);

    _updateProfile.prepare(partnerUser: partnerUser);

    _updateProfile.showUpdateProfileDialog();
  }

  //For No Game Profile
  Future<void> showgameprofilenoti() async {
    NotificationDetails platformChannelSpecifics =
        setUpPlatformSpecifics('gameprofile', 'gameprofile', song: null);

    await _flutterLocalNotificationsPlugin.show(
      0,
      "Welcome to MoonGo",
      "Please add game profile for other players to play with you",
      platformChannelSpecifics,
      payload: GameProfileAdd,
    );
  }

  _showBookingDialog(message) async {
    int userId = 0;
    int bookingId = 0;
    int bookingUserId = 0;
    // ignore: unused_local_variable
    int gameType = 0;
    String gameName = '';
    String type = '';
    String bookingUserName = '';

    if (Platform.isAndroid) {
      userId = json.decode(message['data']['user_id']);
      bookingId = json.decode(message['data']['id']);
      bookingUserId = json.decode(message['data']['booking_user_id']);
      gameType = json.decode(message['data']['game_type']);
      gameName = message['data']['game_name'];
      type = message['data']['type'];
      bookingUserName = message['data']['name'];
    } else if (Platform.isIOS) {
      userId = json.decode(message['user_id']);
      bookingId = json.decode(message['id']);
      bookingUserId = json.decode(message['booking_user_id']);
      gameType = json.decode(message['game_type']);
      gameName = message['game_name'];
      type = message['type'];
      bookingUserName = message['name'];
    } else {
      showToast('This platform is not supported');
      return;
    }

    _bookingManager.bookingPrepare(
      bookingUserName: bookingUserName,
      gameName: gameName,
      type: type,
      userId: userId,
      bookingId: bookingId,
      bookingUserId: bookingUserId,
    );
    _bookingManager.showBookingDialog();
  }

  //For booking Fcm
  Future<void> _showBookingNotification(message) async {
    final context = locator<NavigationService>().navigatorKey.currentContext;
    BlocProvider.of<UserNewNotificationBloc>(context)
        .add(UserNewNotificationRefreshedFromStartPageToCurrentPage());
    NotificationDetails platformChannelSpecifics =
        setUpPlatformSpecifics('booking', 'Booking', song: 'moonblink_noti');
    int userId = 0;
    int bookingId = 0;
    int bookingUserId = 0;
    int gameType = 0;
    String gameName = '';
    String type = '';
    String bookingUserName = '';

    String title = '';
    String body = '';

    String payload = '';

    if (Platform.isAndroid) {
      userId = json.decode(message['data']['user_id']);
      bookingId = json.decode(message['data']['id']);
      bookingUserId = json.decode(message['data']['booking_user_id']);
      gameType = json.decode(message['data']['game_type']);
      gameName = message['data']['game_name'];
      type = message['data']['type'];
      bookingUserName = message['data']['name'];

      title = message['notification']['title'].toString();
      body = message['notification']['body'].toString();
      payload = message['data']['fcm_type'];
    } else if (Platform.isIOS) {
      userId = json.decode(message['user_id']);
      bookingId = json.decode(message['id']);
      bookingUserId = json.decode(message['booking_user_id']);
      gameType = json.decode(message['game_type']);
      gameName = message['game_name'];
      type = message['type'];
      bookingUserName = message['name'];

      title = message['aps']['alert']['title'].toString();
      body = message['aps']['alert']['body'].toString();
      payload = message['fcm_type'];
    } else {
      showToast('This platform is not supported');
      return;
    }

    _bookingManager.bookingPrepare(
      bookingUserName: bookingUserName,
      gameName: gameName,
      type: type,
      userId: userId,
      bookingId: bookingId,
      bookingUserId: bookingUserId,
    );

    await _flutterLocalNotificationsPlugin.show(
        0, title.toString(), body.toString(), platformChannelSpecifics,
        payload: payload);
  }

  _showBoostingDialog(message) async {
    int userId = 0;
    int bookingId = 0;
    int bookingUserId = 0;
    String gameName = '';
    String bookingUserName = '';

    int estimateCost = 0;
    int estimateDay = 0;
    int estimateHour = 0;
    String rankFrom = '';
    String upToRank = '';

    String title = '';
    String body = '';

    String payload = '';

    if (Platform.isAndroid) {
      userId = json.decode(message['data']['user_id']);
      bookingId = json.decode(message['data']['id']);
      bookingUserId = json.decode(message['data']['booking_user_id']);
      gameName = message['data']['game_name'];
      bookingUserName = message['data']['name'];
      estimateCost = json.decode(message['data']['estimate_cost']);
      estimateDay = json.decode(message['data']['estimate_day']);
      estimateHour = json.decode(message['data']['estimate_hour']);
      rankFrom = message['data']['rank_from'];
      upToRank = message['data']['up_to_rank'];

      title = message['notification']['title'].toString();
      body = message['notification']['body'].toString();
      payload = message['data']['fcm_type'];
    } else if (Platform.isIOS) {
      userId = json.decode(message['user_id']);
      bookingId = json.decode(message['id']);
      bookingUserId = json.decode(message['booking_user_id']);
      gameName = message['game_name'];
      bookingUserName = message['name'];
      estimateCost = json.decode(message['estimate_cost']);
      estimateDay = json.decode(message['estimate_day']);
      estimateHour = json.decode(message['estimate_hour']);
      rankFrom = message['rank_from'];
      upToRank = message['up_to_rank'];

      title = message['aps']['alert']['title'].toString();
      body = message['aps']['alert']['body'].toString();
      payload = message['fcm_type'];
    } else {
      showToast('This platform is not supported');
      return;
    }

    _boostingManager.boostingPrepare(
        userId,
        bookingId,
        bookingUserId,
        bookingUserName,
        gameName,
        estimateCost,
        estimateDay,
        estimateHour,
        rankFrom,
        upToRank);
    _boostingManager.showBoostingDialog();
  }

  //For boosting Fcm
  Future<void> _showBoostingNotification(message) async {
    final context = locator<NavigationService>().navigatorKey.currentContext;
    BlocProvider.of<UserNewNotificationBloc>(context)
       .add(UserNewNotificationRefreshedFromStartPageToCurrentPage());
    NotificationDetails platformChannelSpecifics =
        setUpPlatformSpecifics('boosting', 'Boosting', song: 'moonblink_noti');
    int userId = 0;
    int bookingId = 0;
    int bookingUserId = 0;
    String gameName = '';
    String bookingUserName = '';

    int estimateCost = 0;
    int estimateDay = 0;
    int estimateHour = 0;
    String rankFrom = '';
    String upToRank = '';

    String title = '';
    String body = '';

    String payload = '';

    if (Platform.isAndroid) {
      userId = json.decode(message['data']['user_id']);
      bookingId = json.decode(message['data']['id']);
      bookingUserId = json.decode(message['data']['booking_user_id']);
      gameName = message['data']['game_name'];
      bookingUserName = message['data']['name'];
      estimateCost = json.decode(message['data']['estimate_cost']);
      estimateDay = json.decode(message['data']['estimate_day']);
      estimateHour = json.decode(message['data']['estimate_hour']);
      rankFrom = message['data']['rank_from'];
      upToRank = message['data']['up_to_rank'];

      title = message['notification']['title'].toString();
      body = message['notification']['body'].toString();
      payload = message['data']['fcm_type'];
    } else if (Platform.isIOS) {
      userId = json.decode(message['user_id']);
      bookingId = json.decode(message['id']);
      bookingUserId = json.decode(message['booking_user_id']);
      gameName = message['game_name'];
      bookingUserName = message['name'];
      estimateCost = json.decode(message['estimate_cost']);
      estimateDay = json.decode(message['estimate_day']);
      estimateHour = json.decode(message['estimate_hour']);
      rankFrom = message['rank_from'];
      upToRank = message['up_to_rank'];

      title = message['aps']['alert']['title'].toString();
      body = message['aps']['alert']['body'].toString();
      payload = message['fcm_type'];
    } else {
      showToast('This platform is not supported');
      return;
    }
    _boostingManager.boostingPrepare(
        userId,
        bookingId,
        bookingUserId,
        bookingUserName,
        gameName,
        estimateCost,
        estimateDay,
        estimateHour,
        rankFrom,
        upToRank);

    await _flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics,
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
        importance: Importance.max,
        priority: Priority.high,
        ongoing: true,
        sound: RawResourceAndroidNotificationSound('moonblink_noti'),
        autoCancel: false);

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

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
        importance: Importance.max,
        priority: Priority.high,
      );
      var iOSPlatformChannelSpecifics = IOSNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'moonblink_noti.m4r');
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
      return platformChannelSpecifics;
    } else {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.moonuniverse.moonblink.$name', //same package name for both platform
        'Moon Blink $channelName',
        'Moon Blink',
        playSound: true,

        enableVibration: true,
        importance: Importance.max,
        priority: Priority.high,
      );
      var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
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
    StorageManager.sharedPreferences.setInt(kPartnerUserIdForChat, partnerId);
  }

  void navigateToChatBox() {
    bool atChatBox = StorageManager.sharedPreferences.get(isUserAtChatBox);
    if (_partnerId == null) {
      this._partnerId =
          StorageManager.sharedPreferences.getInt(kPartnerUserIdForChat);
    }
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
      context: locator<NavigationService>()
          .navigatorKey
          .currentState
          .overlay
          .context,
      builder: (context) => UpdateProfileDialog(
        partnerUser: this.partnerUser,
        navigateToProfilePage: () => this.navigateToUpdateProfile(),
      ),
    );
  }
}

void navigatotogameprofile() {
  locator<NavigationService>().navigateTo(RouteName.chooseUserPlayGames);
}
