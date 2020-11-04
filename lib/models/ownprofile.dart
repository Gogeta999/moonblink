import 'package:moonblink/models/partner.dart';
import 'package:moonblink/models/wallet.dart';

class OwnProfile {
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
  String level;
  String leftorder;
  String ordercount;
  String ordertaking;
  String levelpercent;
  String levelresettime;
  Wallet wallet;
  PartnerProfile prfoileFromPartner;

  // String partnerProfileImage;
  // String partnerBackendImage;
  OwnProfile({
    this.partnerId,
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
    this.level,
    this.leftorder,
    this.ordercount,
    this.ordertaking,
    this.levelpercent,
    this.levelresettime,
    this.wallet,
    this.prfoileFromPartner,
  });

  factory OwnProfile.fromJson(Map<String, dynamic> map) {
    return OwnProfile(
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
      level: map['account_level'],
      leftorder: map['need_to_take_order'],
      ordercount: map['next_level_order_count'],
      ordertaking: map['order_taking'],
      levelpercent: map['level_percentage'],
      levelresettime: map['level_reset_time'],
      wallet: Wallet.fromJson(map['wallet']),
      prfoileFromPartner: PartnerProfile.fromJson(
        map['profile'],
      ),
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
