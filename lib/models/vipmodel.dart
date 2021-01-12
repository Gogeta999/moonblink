class VIPprice {
  final int vip;
  final int updatecost;
  final int postupload;
  final int followerpost;
  final int publicpost;
  final int expiretime;

  VIPprice(
      {this.vip,
      this.updatecost,
      this.postupload,
      this.followerpost,
      this.publicpost,
      this.expiretime});

  VIPprice.fromJson(Map<String, dynamic> json)
      : vip = json['vip'],
        updatecost = json['update_cost'],
        postupload = json['post_upload'],
        followerpost = json['only_follower_post'],
        publicpost = json['public_post'],
        expiretime = json['expire_at'];
}
