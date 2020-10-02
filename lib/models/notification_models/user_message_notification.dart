
class UserMessageNotificationResponse {
  final List<UserMessageNotificationData> data;

  UserMessageNotificationResponse({this.data});

  factory UserMessageNotificationResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataJson = json['data'];

    List<UserMessageNotificationData> dataList =
    dataJson.map((e) => UserMessageNotificationData.fromJson(e)).toList();

    return UserMessageNotificationResponse(data: dataList);
  }
}

class UserMessageNotificationData {
  final int id;
  final int userId;
  final String fcmType;
  final String title;
  final String message;
  final int isRead;
  final String createdAt;
  final String updatedAt;
  final UserMessageNotificationMessageData messageData;

  UserMessageNotificationData({this.id, this.userId, this.fcmType, this.title, this.message, this.isRead, this.createdAt, this.updatedAt, this.messageData});

  UserMessageNotificationData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        fcmType = json['fcm_type'],
        title = json['title'],
        message = json['message'],
        isRead = json['is_read'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        messageData = UserMessageNotificationMessageData.fromJson(json['data']);
}

class UserMessageNotificationMessageData {
  final int roomId;
  final int senderId;
  final String msg;
  final int type;
  final String attach;
  final String updatedAt;
  final String createdAt;
  final int id;
  final String fcmType;
  final String clickAction;

  UserMessageNotificationMessageData.fromJson(Map<String, dynamic> json)
      : roomId = json['room_id'],
        senderId = json['sender_id'],
        msg = json['msg'],
        type = json['type'],
        attach = json['attach'],
        updatedAt = json['updated_at'],
        createdAt = json['created_at'],
        id = json['id'],
        fcmType = json['fcm_type'],
        clickAction = json['click_action'];
}
