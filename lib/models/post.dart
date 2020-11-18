class Post {
  final int id;
  final String userName;
  final String createdAt;
  final int updatedAt;
  int reactionCount;
  final String profileImage;
  final String coverImage;
  int isReacted;
  final int type;
  final String gender;

  Post.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userName = json['name'],
        createdAt = json['created_at'],
        updatedAt = DateTime.parse(json['updated_at']).millisecondsSinceEpoch,
        reactionCount = json['reaction_count'],
        profileImage = json['profile_image'],
        coverImage = json['cover_image'],
        isReacted = json['is_reacted'],
        type = json['type'],
        gender = json['gender'] ?? "";

  Post.fromMap(Map<String, dynamic> json)
      : id = json['id'],
        userName = json['name'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        reactionCount = json['reaction_count'],
        profileImage = json['profile_image'],
        coverImage = json['cover_image'],
        isReacted = json['is_reacted'],
        type = json['type'],
        gender = json['gender'] ?? "";

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': userName,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'reaction_count': reactionCount,
        'profile_image': profileImage,
        'cover_image': coverImage,
        'is_reacted': isReacted,
        'type': type,
        'gender': gender
      };
}
