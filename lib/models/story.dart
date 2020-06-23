class Story{
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
  // Story({this.id, this.userId, this.body,
  //        this.mediaUrl, this.status, this.expiredAt,
  //        this.createdAt, this.updatedAt});

  

  // factory Story.fromMap(Map<String, dynamic> map){
  //   return Story(
  //     id: map['id'],
  //     userId: map['user_id'],
  //     body: map['body'],
  //     mediaUrl: map['media'],
  //     status: map['status'],
  //     expiredAt: map['expired_at'],
  //     createdAt: map['created_at'],
  //     updatedAt: map['updated_at']
  //   );
  // }
  static Story fromMap(Map<String, dynamic> map){
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
  }

  Map toJson() => {
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