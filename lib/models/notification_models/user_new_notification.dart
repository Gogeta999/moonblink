import 'package:moonblink/models/notification_models/user_booking_notification.dart';
import 'package:moonblink/models/notification_models/user_message_notification.dart';

class UserNewNotificationResponse {
  final List<UserNewNotificationData> data;
  final int unreadCount;

  UserNewNotificationResponse({this.data, this.unreadCount});

  factory UserNewNotificationResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataJson = json['data'];
    int unread = json['unread_count'];

    List<UserNewNotificationData> dataList =
    dataJson.map((e) {
      final temp = UserNewNotificationData.fromJson(e);
      temp.decodeData(e);
      return temp;
    }).toList();

    return UserNewNotificationResponse(data: dataList, unreadCount: unread);
  }
}

class UserNewNotificationData {
  final int id;
  final int userId;
  final String fcmType;
  final String title;
  final String message;
  final int isRead;
  final String createdAt;
  final String updatedAt;
  var data;

  UserNewNotificationData({this.id, this.userId, this.fcmType, this.title, this.message, this.isRead, this.createdAt, this.updatedAt, this.data});

  UserNewNotificationData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        fcmType = json['fcm_type'],
        title = json['title'],
        message = json['message'],
        isRead = json['is_read'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  decodeData(Map<String, dynamic> json) {
    if (fcmType == 'booking') {
      data = UserBookingNotificationData.fromJson(json);
    } else if (fcmType == 'message') {
      data = UserMessageNotificationData.fromJson(json);
    } else {
      print("--------This notification type is not supported for now--------");
    }
  }
}