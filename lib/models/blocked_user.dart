class BlockedUsersList {
  final List<BlockedUser> blockedUsersList;

  BlockedUsersList({this.blockedUsersList});

  factory BlockedUsersList.fromJson(Map<String, dynamic> json){
    List<dynamic> dataJson = json['data'];

    List<BlockedUser> blockedUsersList =  dataJson.map((e) => BlockedUser.fromJson(e)).toList();

    return BlockedUsersList(blockedUsersList: blockedUsersList);
  }

  @override
  String toString() => 'gameList: ${blockedUsersList[0].blockUserId}';
}

class BlockedUser {
  final int id;
  final int userId;
  final int blockUserId;
  final String createdAt;
  final String updatedAt;
  final String name;
  final String profileImage;

  BlockedUser({this.id, this.userId, this.blockUserId, this.createdAt,
      this.updatedAt, this.name, this.profileImage});

  BlockedUser.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        blockUserId = json['block_user_id'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        name = json['name'],
        profileImage = json['profile_image'];


  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'block_user_id': blockUserId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'name': name,
    'profile_image': profileImage
  };
}