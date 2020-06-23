class Post {
  int userID;
  String userName;
  String creatdAt;
  int reactionCount;
  String profileImage;

  static Post fromMap(Map<String, dynamic> map){
    if (map == null) return null;
    Post postBean = Post();
    postBean.userID = map['id'];
    postBean.userName = map['name'];
    postBean.creatdAt = map['created_at'];
    postBean.reactionCount = map['reaction_count'];
    postBean.profileImage = map['profile_image'];
    return postBean;
  }

  Map toJson() => {
    'id': userID,
    'name': userName,
    'created_at': creatdAt,
    'reaction_count': reactionCount,
    'profile_image': profileImage
  };
}