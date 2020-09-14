class PartnerUser {
  int partnerId;
  String partnerName;
  String partnerLastName;
  String partnerEmail;
  // String partnerProfile;
  // String partnerCover;
  // String partnerBios;
  int verified;
  String verifiedAt;
  String createdAt;
  String updatedAt;
  int status;
  int type;
  int typestatus;
  String mlplayerid;
  String pubgplayerid;
  String password; // own Profile
  int followerCount;
  int followingCount; // own Profile
  int reactionCount;
  int isFollow;
  int likecount;
  double rating;
  PartnerProfile prfoileFromPartner;
  List<PartnerGameProfile> gameprofile;

  // String partnerProfileImage;
  // String partnerBackendImage;
  PartnerUser(
      {this.partnerId,
      this.partnerName,
      this.partnerLastName,
      this.partnerEmail,
      this.verified,
      this.verifiedAt,
      this.createdAt,
      this.updatedAt,
      this.type,
      this.status,
      this.typestatus,
      this.mlplayerid,
      this.pubgplayerid,
      this.password,
      this.followerCount,
      this.followingCount,
      this.reactionCount,
      this.isFollow,
      this.likecount,
      this.rating,
      this.prfoileFromPartner,
      this.gameprofile});

  factory PartnerUser.fromJson(Map<String, dynamic> map) {
    return PartnerUser(
      partnerId: map['id'],
      partnerName: map['name'],
      partnerLastName: map['last_name'],
      partnerEmail: map['email'],
      password: map['pass_word'],
      type: map['type'],
      typestatus: map['type_status'],
      status: map['status'],
      followerCount: map['follower_count'],
      followingCount: map['following_count'],
      reactionCount: map['reaction_count'],
      isFollow: map['is_follow'],
      mlplayerid: map['ml_player_id'],
      pubgplayerid: map['pubg_player_id'],
      likecount: map['reaction_count'],
      rating: map['rating'],
      verified: map['verified'],
      verifiedAt: map['verified_at'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      prfoileFromPartner: PartnerProfile.fromJson(
        map['profile'],
      ),
      gameprofile: map['game_profile']
          .map<PartnerGameProfile>((e) => PartnerGameProfile.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = partnerId;
    data['name'] = partnerName;
    data['last_name'] = partnerLastName;
    data['email'] = partnerEmail;
    data['verified'] = verified;
    data['verified_at'] = verifiedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['type'] = type;
    data['type_status'] = typestatus;
    data['status'] = status;
    data['follower_count'] = followerCount;
    data['reaction_count'] = reactionCount;
    data['is_follow'] = isFollow;
    data['ml_player_id'] = mlplayerid;
    data['pubg_player_id'] = pubgplayerid;
    data['reaction_count'] = likecount;
    data['rating'] = rating;
    // data['profile'] = profileFromPartner;
    // 'profile'] =partnerProfileImage;
    return data;
  }
}

class PartnerProfile {
  int partnerId;
  int userId;
  String phone;
  String mail;
  String address;
  String profileImage;
  String coverImage;
  String dob;
  String gender;
  String nrc;
  String bios;
  String createdAt;
  String updatedAt;

  PartnerProfile(
      {this.partnerId,
      this.userId,
      this.phone,
      this.mail,
      this.address,
      this.profileImage,
      this.coverImage,
      this.dob,
      this.gender,
      this.nrc,
      this.bios,
      this.createdAt,
      this.updatedAt});

  factory PartnerProfile.fromJson(Map<String, dynamic> map) {
    return PartnerProfile(
        partnerId: map['id'],
        userId: map['user_id'],
        phone: map['phone'],
        mail: map['mail'],
        address: map['address'],
        profileImage: map['profile_image'],
        coverImage: map['cover_image'],
        dob: map['dob'],
        gender: map['gender'],
        nrc: map['nrc'],
        bios: map['bios'],
        createdAt: map['created_at'],
        updatedAt: map['updated_at']);
  }
}

// PartnerUser.fromJsonMap(Map <String, dynamic> map) :

// partnerId = map['id'],
// partnerName = map['name'],
// partnerLastName = map['last_name'],
// partnerEmail = map['email'],
// partnerProfile = map['profile_image'],
// partnerCover = map['cover_image'],
// partnerBios = map['bios'],
// verified = map['verified'],
// verifiedAt = map['verified_at'],
// createdAt = map['created_at'],
// updatedAt = map['updated_at'],
// type = map['type'],
// followerCount = map['follower_count'],
// isFollow = map['is_follow'],
// prfoileFromPartner = map['profile'];
// // partnerProfileImage = map['profile'],

// Map<String, dynamic> toJson(){
//   final Map<String, dynamic> data = new Map<String, dynamic>();
//   data['id'] = partnerId;
//   data['name'] = partnerName;
//   data['last_name'] = partnerLastName;
//   data['email'] = partnerEmail;
//   data['profile_image'] = partnerProfile;
//   data['cover_image'] = partnerCover;
//   data['bios'] = partnerBios;
//   data['verified'] = verified;
//   data['verified_at'] = verifiedAt;
//   data['created_at'] = createdAt;
//   data['updated_at'] = updatedAt;
//   data['type'] = type;
//   data['follower_count'] = followerCount;
//   data['is_follow'] = isFollow;
//   // data['profile'] = profileFromPartner;
//   // 'profile'] =partnerProfileImage;
//   return data;
// }

//   PartnerProfile.fromJsonMap(Map <String, dynamic> map) :
//   partnerId = map['id'],
//   userId = map['user_id'],
//   phone = map['phone'],
//   mail = map['mail'],
//   address = map['address'],
//   profileImage = map['profile_image'],
//   coverImage = map['cover_image'],
//   dob = map['dob'],
//   gender = map['gender'],
//   nrc = map['nrc'],
//   bios = map['bios'],
//   createdAt = map['created_at'],
//   updatedAt = map['updated_at'];
//   Map<String, dynamic> toJson(){
//   final Map<String, dynamic> data = new Map<String, dynamic>();
//   data['id'] = partnerId;
//   data['user_id'] = userId;
//   data['phone'] = phone;
//   data['mail'] = mail;
//   data['address'] = address;
//   data['profile_image'] = profileImage;
//   data['cover_image'] = coverImage;
//   data['dob'] = dob;
//   data['gender'] = gender;
//   data['nrc'] = nrc;
//   data['bios'] = bios;
//   data['created_at'] = createdAt;
//   data['updated_at'] = updatedAt;
// }
class PartnerGameProfile {
  final int id;
  final int userId;
  final int gameId;
  final String gameName;
  final String playerId;
  final String level;
  final String skillCoverImage;
  final String aboutOrderTaking;
  final int isPlay;
  final String createdAt;
  final String updatedAt;

  PartnerGameProfile(
      {this.id,
      this.userId,
      this.gameId,
      this.gameName,
      this.playerId,
      this.level,
      this.skillCoverImage,
      this.aboutOrderTaking,
      this.isPlay,
      this.createdAt,
      this.updatedAt});

  PartnerGameProfile.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        gameId = json['game_id'],
        gameName = json['game_name'],
        playerId = json['player_id'],
        level = json['level'],
        skillCoverImage = json['skill_cover_image'],
        aboutOrderTaking = json['about_order_taking'],
        isPlay = json['is_play'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'game_id': gameId,
        'game_name': gameName,
        'player_id': playerId,
        'level': level,
        'skill_cover_image': skillCoverImage,
        'about_order_taking': aboutOrderTaking,
        'is_play': isPlay,
        'created_at': createdAt,
        'updated_at': updatedAt
      };
}
