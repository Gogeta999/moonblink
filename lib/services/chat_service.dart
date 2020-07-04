import 'dart:convert';
import 'dart:typed_data';
import 'package:moonblink/base_widget/notifications.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/callmodel.dart';
import 'package:moonblink/models/chatlist.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../base_widget/notifications.dart';


  String now = DateTime.now().toString();
  IO.Socket socket = IO.io('http://54.179.117.84', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  String usertoken = StorageManager.sharedPreferences.getString(token);
  int userid = StorageManager.sharedPreferences.getInt(mUserId);
  // List<User> friendList = List<User>();
  List<Message> messages = List<Message>();
  List<Files> files = List<Files>();
  List<Chatlist> chatlist = List<Chatlist>();

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  final Map<String, dynamic> _dc_constraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };
  
class ChatModel extends Model{
  //connect
  void init() {
    socket.emit('connect-user', usertoken);
    socket.connect();
    LocalNotifications().init();
    print("Connected Socket");
    //callmade
    socket.on('call-made', (jsondata) {
      //print(jsondata);
      print(jsondata.length);
      var callm = Callmade.fromJson(jsondata);
      print(callm);
      // int callerid = jsondata.map((m) => m['from']);
      // String offer = jsondata.map((m) => m['offer']);
      // String media = jsondata.map((m)=> m['media']);
      // callm = Callmade(offer, callerid, media);
      print("Call is made");
    });
    //answermade
    socket.on('answer-made', (jsondata) {
      print(jsondata.length);
      int callerid = jsondata.map((m) => m['from']);
      String answer = jsondata.map((m) => m['answer']);
      print("Answer");
    }
    );
    ///[NEED TO FIX]
    //receiver-attach
    socket.on("receiver-attach", (data) {
      Map<String, dynamic> fs = json.decode(data);
      files.add(Files(
        fs["0"],data["1"],data["2"],data["3"]
      ));
    }
    );
    //connect user list
    socket.once('connected-users', (jsonData) {
      print(jsonData);
      var connetion_id = jsonData.map((m) => m['connection_id']);
      var user_id = jsonData.map((m) => m['user_id']);
      print(connetion_id);
      print(user_id);
    });
  }

  ///[Chating Text]
  //send messages
  void sendMessage(String text, int receiverChatID, List<Message> msg) {
    msg.insert(0, Message(text, userid, receiverChatID, now, ''));
    print("User ID : $userid");
    print("Receiver ID : $receiverChatID");
    print("Message : $text");
    print("Time : $now");
    socket.emit('chat-message', [
      {"message": text, "sender_id": userid, "receiver_id": receiverChatID}
    ]
        // jsonEncode({
        //   'sender_id': userid,
        //   'receiver_id': receiverChatID,
        //   'message' : text
        // })
        );
    notifyListeners();
  }

  //file message
  void sendfile(String name, Uint8List file, int receiverChatID, List<Message> msg) {
    // msg.insert(0,Message(name, file, userid, receiverChatID));
    print("User ID : $userid");
    print("Receiver ID : $receiverChatID");
    print("Name : $name");
    print("File : ${file.toString()}");
    socket.emit('upload-attach', [
      {
        "name": name,
        "data": file,
        "sender_id": userid,
        "receiver_id": receiverChatID
      }
    ]);
    notifyListeners();
  }

  ///[For Conversation List]
  List<Chatlist> conversationlist() {
    print("Getting Chat List");
    socket.once("conversation", (data){
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
  ///[For receiving message]
  void receiver(List<Message> message) {
    print("Received Messages");
    socket.clearListeners();
    socket.once("receiver-peer", (data) {
      print("Messages");
      print(data);
      receivenoti(data["sender_id"], data["time"],data["message"]);
      message.insert(0,Message(
         data['message'], data['sender_id'], data['receiver_id'], data['time'], '' 
      ));
      notifyListeners();
    }
    );
    socket.once("receiver-attach", (data) {
      print("Images");
      print(data);
      receivenoti(data['sender_id'], data['time'], "File Message");
      message.insert(0, Message("", data['sender_id'], data['receiver_id'], data["time"], data['attach']));
      notifyListeners();
    } 
    );
  }
  void receivenoti(int id, String text, String msg) {
    LocalNotifications().notification(id, text, msg);
  }
  
  //Answermade
  // void answermade() {
  //   socket.on('answer-made', (jsondata) {
  //     // Map<String, dynamic> data = json.decode(jsondata);
  //     int callerid = jsondata.map((m) => m['from']);
  //     String answer = jsondata.map((m) => m['answer']);
  //     Answermade(callerid, answer);
  //   }
  //   );
  // }

  ///[For Voice Call]
  //Create Answer
  void createOffer(
      int receiverChatID, RTCPeerConnection pc, String media) async {
    try {
      RTCSessionDescription s = await pc
          .createOffer(media == 'data' ? _dc_constraints : _constraints);
      pc.setLocalDescription(s);
      socket.emit('call-user', [
        userid,
        16,
        s.sdp,
        // 'session_id': this._sessionId,
        media,
      ]);
    } catch (e) {
      print(e.toString());
    }
  }

  //To answer call
  void createAnswer(int receiverChatID, RTCPeerConnection pc, media) async {
    try {
      RTCSessionDescription s = await pc
          .createAnswer(media == 'data' ? _dc_constraints : _constraints);
      pc.setLocalDescription(s);
      socket.emit('make-answer', [
        userid,
        16,
        s.sdp,
      ]);
    } catch (e) {
      print(e.toString());
    }
  }

  //end call
  void bye() {
    socket.emit("bye", []);
  }
  // ///[get Messages]
  // List<Message> getMessagesForChatID(int id) {
  //   print("Get Messages");
  //   // message(id);

  //   print(messages);
  //   // notifyListeners();
  //   return messages
  //     .where((msg) => msg.senderID == id || msg.receiverID == id)
  //     .toList();     
  // }
  // List<Files> getAttachForChatID(int id) {
  //   print("Get Attachment");
  //   return files
  //   .where((file) => file.senderID == id || file.receiverID == id)
  //   .toList();
  // }
  void disconnect(){
    socket.disconnect();
  }
}