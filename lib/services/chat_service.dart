import 'dart:typed_data';
// import 'package:flutter_webrtc/webrtc.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/global/storage_manager.dart';
// import 'package:moonblink/models/callmodel.dart';
import 'package:moonblink/models/chatlist.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/message.dart';

String url = 'https://chat.moonblinkuniverse.com';
String now = DateTime.now().toString();
IO.Socket socket = IO.io(url, <String, dynamic>{
  'transports': ['websocket'],
  'autoConnect': false,
});


// List<Message> messages = List<Message>();
List<Files> files = List<Files>();
List<Chatlist> chatlist = List<Chatlist>();
Bookingstatus bookingdata;

class ChatModel extends Model {
  //connect
  void init() {
    String usertoken = StorageManager.sharedPreferences.getString(token);
    socket.connect();
    socket.emit('connect-user', usertoken);
    socket.once("booking_status", (data) => print(data));
    if (socket.connect() != null) {
      print("Connected Socket");
    }
    // //call made
    // socket.once("call-made", (data) => null);
    // //answer-made
    // socket.once("made-answer", (data) => null);
    // //call rejected
    // socket.once("call-rejected", (data) => null);
    //connect user list
    socket.once('connected-users', (jsonData) {
      print(jsonData);
      var connectionId = jsonData.map((m) => m['connection_id']);
      var userId = jsonData.map((m) => m['user_id']);
      print(connectionId);
      print(userId);
    });
  }

  ///[Chating Text]
  //send messages
  void sendMessage(String text, int receiverChatID, List<Message> msg) {
    int userid = StorageManager.sharedPreferences.getInt(mUserId);
    msg.insert(0, Message(text, userid, receiverChatID, now, '', 0));
    print("User ID : $userid");
    print("Receiver ID : $receiverChatID");
    print("Message : $text");
    print("Time : $now");
    socket.emit('chat-message', [
      {
        "message": text,
        "sender_id": userid,
        "receiver_id": receiverChatID,
        "type": 0
      }
    ]);
    notifyListeners();
  }

  //file message
  void sendfile(String name, Uint8List file, int receiverChatID, int type,
      List<Message> msg) {
    int userid = StorageManager.sharedPreferences.getInt(mUserId);
    String local = new String.fromCharCodes(file);
    msg.insert(0, Message(name, userid, receiverChatID, now, local, 5));
    print("User ID : $userid");
    print("Receiver ID : $receiverChatID");
    print("Name : $name");
    //print("File : ${file.toString()}");
    socket.emit('upload-attach', [
      {
        "name": name,
        "data": file,
        "sender_id": userid,
        "receiver_id": receiverChatID,
        "media_type": type
      }
    ]);
    notifyListeners();
  }

  //file message
  void sendaudio(String name, Uint8List file, int receiverChatID, int type,
      List<Message> msg, String path) {
    int userid = StorageManager.sharedPreferences.getInt(mUserId);
    // String local = new String.fromCharCodes(file);
    msg.insert(0, Message(name, userid, receiverChatID, now, path, 6));
    print("User ID : $userid");
    print("Receiver ID : $receiverChatID");
    print("Name : $name");
    print("File Path : $path");
    //print("File : ${file.toString()}");
    socket.emit('upload-attach', [
      {
        "name": name,
        "data": file,
        "sender_id": userid,
        "receiver_id": receiverChatID,
        "media_type": type
      }
    ]);
    notifyListeners();
  }

  //call
  void call(int fromId, int toId, String voiceCallChannelName) {
    print("from ID : $fromId");
    print("to ID : $toId");
    print('channelName : $voiceCallChannelName');
    print("Time : $now");
    socket.emit('call-user', [
      {'from': fromId, 'to': toId, 'voiceCallChannelName': voiceCallChannelName}
    ]);
    notifyListeners();
  }

  ///[For Conversation List]
  List<Chatlist> conversationlist() {
    print("Getting Chat List");
    socket.once("conversation", (data) {
      print(data);
      chatlist.clear();
      // LocalNotifications().notification(1,"new", "message");
      var response = ResponseData.fromJson(data);
      for (var i = 0; i < response.data.length; i++) {
        Chatlist chat = Chatlist.fromMap(response.data[i]);
        chatlist.add(chat);
      }
      notifyListeners();
    });
    return chatlist;
  }

  Bookingstatus chatupdated() {
    print("Chat Updated");
    socket.on("chat-updated", (data) {
      bookingdata = Bookingstatus(data["booking_id"], data["user_id"],
          data["booking_user_id"], data["status"]);
      print(data.toString());
      print(bookingdata.bookingid);
      print(bookingdata.id);
      print(bookingdata.bookinguserid);
      print(bookingdata.status);
      notifyListeners();
    });

    return bookingdata;
  }

  void chatupdating(otherid) {
    int userid = StorageManager.sharedPreferences.getInt(mUserId);
    print("Chat Updating");
    socket.emit("chat-updating", [
      {"sender_id": userid, "receiver_id": otherid}
    ]);
  }

  ///[For receiving message]
  void receiver(List<Message> message) {
    print("Received Messages");
    socket.clearListeners();
    socket.on("receiver-peer", (data) {
      message.insert(
          0,
          Message(data['message'], data['sender_id'], data['receiver_id'],
              data['time'], '', data["type"]));
      print("msg added");
      notifyListeners();
    });
    socket.on("receiver-attach", (data) {
      print(data);
      message.insert(
          0,
          Message("", data['sender_id'], data['receiver_id'], data["time"],
              data['attach'], data['type']));
      notifyListeners();
    });
  }

  void receivenoti(int id, String text, String msg) {
    // PushNotificationsManager().notification(id, text, msg);
  }

  void disconnect() {
    socket.disconnect();
    print("Disconnected");
  }

  void send(event, data) {
    socket.emit(event, data);
  }
}
