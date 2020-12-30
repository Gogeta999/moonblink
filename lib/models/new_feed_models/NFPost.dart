class NFPost {
  final int id;
  final int userId;
  final String body;
  final List<String> media;
  final int status;
  final String createdAt;
  final String updatedAt;
  final int reactionCount;
  final String name;
  final String profile;
  final int isReacted;
  final String bios;

  NFPost.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      userId = json['user_id'],
      body = json['body'],
      media = json['media'].map<String>((e) => e.toString()).toList(),
      status = json['status'],
      createdAt = json['created_at'],
      updatedAt = json['updated_at'],
      reactionCount = json['reaction_count'],
      name = json['user']['name'],
      profile = json['user']['profile_image'],
      isReacted = json['user']['is_reacted'],
      bios = json['user']['bios'];
}