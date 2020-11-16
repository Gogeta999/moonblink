import 'package:moonblink/models/contact.dart';

class Follower {
  int partnerId;
  int userId;
  int followerId;
  int followingStatus;
  // String createdAt;
  ContactUser contactUser;

  Follower(
      {this.partnerId,
      this.userId,
      this.followerId,
      this.followingStatus,
      // this.createdAt,
      this.contactUser});

  factory Follower.fromJson(Map<String, dynamic> map) {
    return Follower(
        partnerId: map['id'],
        userId: map['user_id'],
        followerId: map['follower_id'],
        followingStatus: map['status'],
        // createdAt: map['created_at'],
        contactUser: ContactUser.fromJson(map['follower']));
  }
}
