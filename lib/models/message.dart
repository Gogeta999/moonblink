import 'dart:typed_data';

class Files{
  final String name;
  final Uint8List file;
  final int senderID;
  final int receiverID;

  Files(this.name,this.file,this.senderID,this.receiverID);
}
class Message{
  final String text;
  final int senderID;
  final int receiverID;
  final String now;

  Message(this.text,this.senderID,this.receiverID, this.now);
}