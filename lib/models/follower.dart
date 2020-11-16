class Follower {
  int partnerId;
  int userId;
  int followerId;
  int followingStatus;
  String createdAt;
  String name;
  int type;
  String profileimage;

  Follower({
    this.partnerId,
    this.userId,
    this.followerId,
    this.followingStatus,
    this.createdAt,
    this.name,
    this.type,
    this.profileimage,
  });

  factory Follower.fromJson(Map<String, dynamic> map) {
    return Follower(
        partnerId: map['id'],
        userId: map['user_id'],
        followerId: map['follower_id'],
        followingStatus: map['status'],
        createdAt: map['created_at'],
        name: map['name'],
        type: map['type'],
        profileimage: map['profile_image']);
  }
}
