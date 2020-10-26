class LastMessage {
  int id;
  int roomId;
  int senderId;
  int receiverId;
  String message;
  int type;
  String attach;
  String createdAt;
  String updatedAt;
  String booking;

  LastMessage.fromJson(Map<String, dynamic> json)
      :
    id = json['id'],
    roomId = json['room_id'],
    senderId = json['sender_id'],
    receiverId = json['receiver_id'],
    message = json['msg'],
    type = json['type'],
    attach = json['attach'],
    createdAt = json['created_at'],
    updatedAt = json['updated_at'],
    booking = json['booking'];
}