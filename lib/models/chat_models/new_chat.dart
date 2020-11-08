class NewChat {
  final int id;
  final String name;
  final String lastMessageTime;
  final int messages;
  final int type;
  final int canLeave;
  final String createdAt;
  final String updatedAt;
  final String profileImage;
  final String lastMessage;
  final int unread;
  final String lastAttach;
  final int userId;

  NewChat.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        lastMessageTime = json['last_msg_time'],
        messages = json['msgs'],
        type = json['type'],
        canLeave = json['can_leave'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        profileImage = json['profile_image'],
        lastMessage = json['last_message'],
        unread = json['unread'],
        lastAttach = json['last_attach'],
        userId = json['user_id'];
}
