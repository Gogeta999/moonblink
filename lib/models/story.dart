class Story {
  int id;
  int userId;
  String body;
  String mediaUrl;
  int mediaType;
  int status;
  String expiredAt;
  String createdAt;
  String updatedAt;
  String profileImage;
  /*static Story fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    Story storyBean = Story();
    storyBean.id = map['id'];
    storyBean.userId = map['user_id'];
    storyBean.body = map['body'];
    storyBean.mediaType = map['media_type'];
    storyBean.mediaUrl = map['media'];
    storyBean.status = map['status'];
    storyBean.expiredAt = map['expired_at'];
    storyBean.createdAt = map['created_at'];
    storyBean.updatedAt = map['updated_at'];
    storyBean.profileImage = map['profile_image'];
    return storyBean;
  }*/

  Story.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        body = json['body'],
        mediaType = json['media_type'],
        mediaUrl = json['media'],
        status = json['status'],
        expiredAt = json['expired_at'],
        createdAt = json['created_at'],
        updatedAt = json['update_at'],
        profileImage = json['profile_image'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'body': body,
        'media': mediaUrl,
        'media_type': mediaType,
        'status': status,
        'expired_at': expiredAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'profile_image': profileImage,
      };
}
