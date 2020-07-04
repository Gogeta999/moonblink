import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifications{
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  Future<void> init() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    print("noti init");
  }

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
    await flutterLocalNotificationsPlugin.show(
        id, user, message, notificationDetails);
  }
}