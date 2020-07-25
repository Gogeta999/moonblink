class Post {
  int userID;
  String userName;
  String creatdAt;
  int reactionCount;
  String profileImage;
  String coverImage;
  int isReacted;

  static Post fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    Post postBean = Post();
    postBean.userID = map['id'];
    postBean.userName = map['name'];
    postBean.creatdAt = map['created_at'];
    postBean.reactionCount = map['reaction_count'];
    postBean.profileImage = map['profile_image'];
    postBean.coverImage = map['cover_image'];
    postBean.isReacted = map['is_reacted'];
    return postBean;
  }

  Map toJson() => {
        'id': userID,
        'name': userName,
        'created_at': creatdAt,
        'reaction_count': reactionCount,
        'profile_image': profileImage,
        'cover_image': coverImage,
        'is_reacted': isReacted
      };
}
