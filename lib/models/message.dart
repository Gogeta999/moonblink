import 'dart:typed_data';

class Files {
  final String name;
  final Uint8List file;
  final int senderID;
  final int receiverID;

  Files(this.name, this.file, this.senderID, this.receiverID);
}

class Message {
  final String text;
  final int senderID;
  final int receiverID;
  final String now;
  final String attach;
  final int type;

  Message(this.text, this.senderID, this.receiverID, this.now, this.attach,
      this.type);
}

class Lastmsg {
  int id;
  int roomid;
  int sender;
  int receiver;
  String msg;
  int type;
  String attach;
  String created;
  String updated;
  String booking;

  static Lastmsg fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    Lastmsg chat = Lastmsg();
    chat.id = map['id'];
    chat.roomid = map['room_id'];
    chat.sender = map['sender_id'];
    chat.receiver = map['receiver_id'];
    chat.msg = map['msg'];
    chat.type = map['type'];
    chat.attach = map['attach'];
    chat.created = map['created_at'];
    chat.updated = map['updated_at'];
    chat.booking = map['booking'];
    return chat;
  }
}

class Bookingstatus {
  int bookingid;
  int id;
  int bookinguserid;
  int status;

  Bookingstatus(this.bookingid, this.id, this.bookinguserid, this.status);
}
