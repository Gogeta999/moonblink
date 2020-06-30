import 'dart:convert';
import 'dart:typed_data';


import 'package:flutter_webrtc/webrtc.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/generated/intl/messages_en.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/callmodel.dart';
import 'package:moonblink/models/chatlist.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatModel extends Model{
  String now = DateTime.now().toString();
  IO.Socket socket = IO.io('http://54.179.117.84', <String, dynamic>{
   'transports': ['websocket'],
   'autoConnect': false,
  });

  String usertoken= StorageManager.sharedPreferences.getString(token);
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

  //connect
  void init() {
    socket.emit('connect-user', usertoken);
    socket.connect();
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
    //receiver peer
    socket.on("receiver-peer", (data) {
      print(data);
      Map<String, dynamic> msgs = json.decode(data);
      messages.add(Message(
         msgs['message'], msgs['sender_id'], msgs['receiver_id'], msgs['time']
      ));
      notifyListeners();
    }
    );
    ///[NEED TO FIX]
    //receiver-attach
    socket.on("receiver-attach", (data){ 
      Map<String, dynamic> fs = json.decode(data);
      files.add(Files(
        fs["0"],data["1"],data["2"],data["3"]
      ));
    }
    );
    // ///[Conversation List]
    // socket.on("conversation", (data){
    //   print(data);
    //   var response = ResponseData.fromJson(data);
    //   print(response.data.runtimeType);
    //   for (var i = 0; i < response.data.length; i++) {
    //     var res = Map<String, dynamic>.from(response.data["$i"]);
    //     Chatlist chat = Chatlist.fromMap(res);
    //     chatlist.add(chat);
    //   }
    //   return chatlist;
    // });
    //connect user list
    socket.on('connected-users', (jsonData) {
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
    msg.insert(0, Message( text, userid, receiverChatID, now));
    print("User ID : $userid");
    print("Receiver ID : $receiverChatID");
    print("Message : $text");
    print("Time : $now");
    socket.emit(
      'chat-message',
      [{
        "message": text,
        "sender_id": userid,
        "receiver_id": receiverChatID
      }]    
        // jsonEncode({
        //   'sender_id': userid,
        //   'receiver_id': receiverChatID,
        //   'message' : text
        // })
    );
    notifyListeners();
  }
  //file message
  void filemessage(String name,Uint8List file, int receiverChatID){
    files.add(Files(name, file, userid, receiverChatID));
    print("User ID : $userid");
    print("Receiver ID : $receiverChatID");
    print("Name : $name");
    print("File : ${file.toString()}");
    socket.emit(
      'upload-attach',
      [{
        "name": name,
        "data": file,
        "sender_id": userid,
        "receiver_id": receiverChatID
      }]
    );
    notifyListeners();
  }

  ///[For Conversation List]
  List<Chatlist> conversationlist() {
    print("Getting Chat List");
    socket.on("conversation", (data){
      print(data);
      chatlist.clear();
      var response = ResponseData.fromJson(data);
      for (var i = 0; i < response.data.length; i++) {
        Chatlist chat = Chatlist.fromMap(response.data[i]);
        chatlist.add(chat);
      }
      notifyListeners(); 
      }
    ); 
    return chatlist;  
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
  void createOffer(int receiverChatID, RTCPeerConnection pc, String media) async {
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
    socket.emit("bye", [
    ]);
  }
  ///[get Messages]
  List<Message> getMessagesForChatID(int id) {
    print("Get Messages");
    // message(id);

    print(messages);
    // notifyListeners();
    return messages
      .where((msg) => msg.senderID == id || msg.receiverID == id)
      .toList();     
  }
  List<Files> getAttachForChatID(int id) {
    print("Get Attachment");
    return files
    .where((file) => file.senderID == id || file.receiverID == id)
    .toList();
  }
}
