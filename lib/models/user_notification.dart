class UserNotificationResponse {
  final List<UserNotificationData> data;

  UserNotificationResponse({this.data});

  factory UserNotificationResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataJson = json['data'];

    List<UserNotificationData> dataList =
    dataJson.map((e) => UserNotificationData.fromJson(e)).toList();

    return UserNotificationResponse(data: dataList);
  }
}

class UserNotificationData {
  final int id;
  final int userId;
  final String title;
  final String message;
  final int isRead;
  final String createdAt;
  final String updatedAt;
  final UserNotificationFcmData fcmData;

  UserNotificationData.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      userId = json['user_id'],
      title = json['title'],
      message = json['message'],
      isRead = json['is_read'],
      createdAt = json['created_at'],
      updatedAt = json['updated_at'],
      fcmData = UserNotificationFcmData.fromJson(json['data']);
}

class UserNotificationFcmData {
  final int userId;
  final int bookingUserId;
  final int gameTye;
  final int status;
  final int count;
  final String createdAt;
  final String updatedAt;
  final int id;
  final String fcmType;
  final String name;
  final String clickAction;

  UserNotificationFcmData.fromJson(Map<String, dynamic> json)
    : userId = json['user_id'],
      bookingUserId = json['booking_user_id'],
      gameTye = json['game_type'],
      status = json['status'],
      count = json['count'],
      createdAt = json['created_at'],
      updatedAt = json['updated_at'],
      id = json['id'],
      fcmType = json['fcm_type'],
      name = json['name'],
      clickAction = json['click_action'];
}