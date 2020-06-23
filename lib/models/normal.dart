class NormalUser {
  int normalId;
  String normalName;
  String normalLastName;
  String normalEmail;
  int verified;
  String verifiedAt;
  String createdAt;
  String updatedAt;
  int type;
  int followerCount;
  int isFollow;
  // String normalProfileImage;
  //TODO: add later
  // String normalBackendImage;
  
  NormalUser.fromJsonMap(Map <String, dynamic> map) :

  normalId = map['id'],
  normalName = map['name'],
  normalLastName = map['last_name'],
  normalEmail = map['email'],
  verified = map['verified'],
  verifiedAt = map['verified_at'],
  createdAt = map['created_at'],
  updatedAt = map['updated_at'],
  type = map['type'],
  followerCount = map['follower_count'],
  isFollow = map['is_follow'];
  // normalProfileImage = map['profile'],

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = normalId;
    data['name'] = normalName;
    data['last_name'] = normalLastName;
    data['email'] = normalEmail;
    data['verified'] = verified;
    data['verified_at'] = verifiedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['type'] = type;
    data['follower_count'] = followerCount;
    data['is_follow'] = isFollow;
    // 'profile'] =normalProfileImage;
    return data;
  }
}