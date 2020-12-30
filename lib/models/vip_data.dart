class VipData {
  final int vip;
  final int updateCost;
  final int postUpload;
  final int onlyFollowerPost;
  final int publicPost;
  final int walletValue;
  final int followerCount;

  VipData.fromJson(Map<String, dynamic> json)
    : vip = json['vip']['vip'],
      updateCost = json['vip']['update_cost'],
      postUpload = json['vip']['post_upload'],
      onlyFollowerPost = json['vip']['only_follower_post'],
      publicPost = json['vip']['public_post'],
      walletValue = json['wallet']['value'],
      followerCount = json['follwer_count'];//typo idk
}

/*
  "data": {
    "vip": {
      "vip": 1,
      "update_cost": 300,
      "post_upload": 1,
      "only_follower_post": 1,
      "public_post": 0
    },
    "wallet": {
      "id": 1,
      "user_id": 1,
      "value": 20091180,
      "created_at": "2020-08-24T17:31:18.000000Z",
      "updated_at": "2020-12-30T04:19:48.000000Z",
      "earning_coin": 91200,
      "topup_coin": 19999980
    },
    "follwer_count": 8
  },
*/