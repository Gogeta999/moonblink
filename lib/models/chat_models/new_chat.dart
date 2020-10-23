class NewChat {
  int id;
  String name;
  String lastMessageTime;
  int messages;
  int type;
  int canLeave;
  String createdAt;
  String updatedAt;
  String profileImage;
  String lastMessage;
  int unread;
  String lastAttach;
  int userId;

  NewChat.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        lastMessageTime = map['last_msg_time'],
        messages = map['msgs'],
        type = map['type'],
        canLeave = map['can_leave'],
        createdAt = map['created_at'],
        updatedAt = map['updated_at'],
        profileImage = map['profile_image'],
        lastMessage = map['last_message'],
        unread = map['unread'],
        lastAttach = map['last_attach'],
        userId = map['user_id'];
}
