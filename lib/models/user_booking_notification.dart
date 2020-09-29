
class UserBookingNotificationResponse {
  final List<UserBookingNotificationData> data;

  UserBookingNotificationResponse({this.data});

  factory UserBookingNotificationResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataJson = json['data'];

    List<UserBookingNotificationData> dataList =
        dataJson.map((e) => UserBookingNotificationData.fromJson(e)).toList();

    return UserBookingNotificationResponse(data: dataList);
  }
}

class UserBookingNotificationData {
  final int id;
  final int userId;
  final String title;
  final String message;
  final int isRead;
  final String createdAt;
  final String updatedAt;
  final UserBookingNotificationFcmData fcmData;

  UserBookingNotificationData({this.id, this.userId, this.title, this.message, this.isRead, this.createdAt, this.updatedAt, this.fcmData});

  UserBookingNotificationData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        title = json['title'],
        message = json['message'],
        isRead = json['is_read'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        fcmData = UserBookingNotificationFcmData.fromJson(json['data']);
}

class UserBookingNotificationFcmData {
  final int userId;
  final int bookingUserId;
  final int gameType;
  final int status;
  final int count;
  final String createdAt;
  final String updatedAt;
  final int id;
  final String fcmType;
  final String name;
  final String gameName;
  final String type;
  final String gameIcon; /// null for now
  final String clickAction;

  UserBookingNotificationFcmData.fromJson(Map<String, dynamic> json)
      : userId = json['user_id'],
        bookingUserId = json['booking_user_id'],
        gameType = json['game_type'],
        status = json['status'],
        count = json['count'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        id = json['id'],
        fcmType = json['fcm_type'],
        name = json['name'],
        gameName = json['game_name'],
        type = json['type'],
        gameIcon = json['game_icon'],
        clickAction = json['click_action'];
}
