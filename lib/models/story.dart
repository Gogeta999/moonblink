class Story {
  int id;
  String name;
  String lastname;
  String mail;
  int verified;
  int type;
  int status;
  String created;
  String updated;
  String profile;
  List storys;
  Story({this.id,this.name, this.lastname, this.mail,this.verified,
        this.type,this.status, this.created, this.updated, this.profile, this.storys});
  static Story fromJson(Map<String, dynamic> map) {
    if (map == null) return null;
    Story storyBean = Story();
    storyBean.id = map['id'];
    storyBean.name = map['name'];
    storyBean.lastname = map['body'];
    storyBean.mail = map['mail'];
    storyBean.verified = map['verified'];
    storyBean.type = map['type'];
    storyBean.status = map['status'];
    storyBean.created = map['created_at'];
    storyBean.updated = map['updated_at'];
    storyBean.profile = map['profile_image'];
    storyBean.storys = map['stories'];
    return storyBean;
  }

  // Story.fromJson(Map<String, dynamic> json)
  //     : id = json['id'],
  //       userId = json['user_id'],
  //       body = json['body'],
  //       mediaType = json['media_type'],
  //       mediaUrl = json['media'],
  //       status = json['status'],
  //       expiredAt = json['expired_at'],
  //       createdAt = json['created_at'],
  //       updatedAt = json['update_at'],
  //       profileImage = json['profile_image'],
  //       storys = json['stories'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': name,
        'body': lastname,
        'media': mail,
        'media_type': verified,
        '': type,
        'status': status,
        'created_at': created,
        'updated_at': updated,
        'profile_image': profile,
        'stories': storys
      };
}
class Stories{
  int id;
  int userid;
  String body;
  int type;
  String media;
  int status;
  String expired;
  String created;
  String updated;

  Stories({this.id, this.userid, this.body, this.type,
          this.media, this.status, this.expired, this.created, this.updated});

  factory Stories.fromJson(Map<String, dynamic> map){
    return Stories(
      id: map['id'],
      userid: map['user_id'],
      body: map['body'],
      type: map['media_type'],
      media: map['media'],
      status: map['status'],
      expired: map['expired_at'],
      created: map['created_at'],
      updated: map['updated_at']
    );
  }
}