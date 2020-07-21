class Chatlist {
  int id;
  String name;
  String lastmsgt;
  int msgs;
  int type;
  int leave;
  String created;
  String updated;
  String profile;
  int bookingStatus;
  int bookingid;
  String lastmsg;
  String file;
  int userid;
//  Chatlist({this.id, this.name, this.lastmsg,
//           this.msgs, this.type, this.leave, this.created, this.updated, this.profile});

//  factory Chatlist.fromJson(Map<String, dynamic> map){
//    return Chatlist(
//      id: map['id'],
//      name: map['name'],
//      lastmsg: map['last_msg_time'],
//      msgs: map['msgs'],
//      type: map['type'],
//      leave: map['can_leave'],
//      created: map['created_at'],
//      updated: map['updated_at'],
//      profile: map['profile_image']
//    );
//  }
  static Chatlist fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    Chatlist chat = Chatlist();
    chat.id = map['id'];
    chat.name = map['name'];
    chat.lastmsgt = map['last_msg_time'];
    chat.msgs = map['msgs'];
    chat.type = map['type'];
    chat.leave = map['can_leave'];
    chat.created = map['created_at'];
    chat.updated = map['updated_at'];
    chat.profile = map['profile_image'];
    chat.bookingStatus = map['booking_status'];
    chat.bookingid = map['booking_id'];
    chat.lastmsg = map['last_message'];
    chat.file = map['last_attach'];
    chat.userid = map['user_id'];
    return chat;
  }

  // Map toJson() => {
  //   'id': id,
  //   'name': name,
  //   'last_msg_time': lastmsgt,
  //   'msgs': msgs,
  //   'type': type,
  //   'can_leave': leave,
  //   'created_at': created,
  //   'updated_at': updated,
  //   'profile_image': profile,
  //   'user_id': userid,
  // };
}
