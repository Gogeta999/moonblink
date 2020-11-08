class LastMessage {
  final int id;
  final int roomId;
  final int senderId;
  final int receiverId;
  final String message;
  final int type;
  final String attach;
  final String createdAt;
  final String updatedAt;

  LastMessage(
      this.id,
      this.roomId,
      this.senderId,
      this.receiverId,
      this.message,
      this.type,
      this.attach,
      this.createdAt,
      this.updatedAt);

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
    updatedAt = json['updated_at'];
}