import 'dart:convert';
import 'dart:typed_data';
// import 'package:flutter_webrtc/webrtc.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/global/storage_manager.dart';
// import 'package:moonblink/models/callmodel.dart';
import 'package:moonblink/models/chatlist.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/services/push_notification_manager.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef void OnMessageCallback(String tag, dynamic msg);
typedef void OnCloseCallback(int code, String reason);
typedef void OnOpenCallback();

  const CLIENT_ID_EVENT = 'client-id-event';
  const OFFER_EVENT = 'offer-event';
  const ANSWER_EVENT = 'answer-event';
  const ICE_CANDIDATE_EVENT = 'ice-candidate-event';
  String url = 'http://54.179.117.84';
  String now = DateTime.now().toString();
  IO.Socket socket = IO.io(url, <String, dynamic>{
    'transports': ['websocket'],
    // 'autoConnect': false,
  });

  String usertoken = StorageManager.sharedPreferences.getString(token);
  int userid = StorageManager.sharedPreferences.getInt(mUserId);
  // List<User> friendList = List<User>();
  List<Message> messages = List<Message>();
  List<Files> files = List<Files>();
  List<Chatlist> chatlist = List<Chatlist>();

  // final Map<String, dynamic> _constraints = {
  //   'mandatory': {
  //     'OfferToReceiveAudio': true,
  //     'OfferToReceiveVideo': true,
  //   },
  //   'optional': [],
  // };

  // final Map<String, dynamic> _dc_constraints = {
  //   'mandatory': {
  //     'OfferToReceiveAudio': false,
  //     'OfferToReceiveVideo': false,
  //   },
  //   'optional': [],
  // };
  
class ChatModel extends Model{
  String url;
  OnOpenCallback onOpen;
  OnMessageCallback onMessage;
  OnCloseCallback onClose;
  //connect
  void init() {
    socket.emit('connect-user', usertoken);
    socket.connect();
    // onOpen();
    // LocalNotifications().init();
    print("Connected Socket");
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
        );
    notifyListeners();
  }

  //file message
  void sendfile(String name, Uint8List file, int receiverChatID,int type, List<Message> msg) {
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
        "receiver_id": receiverChatID,
        "media_type": type
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
    PushNotificationsManager().notification(id, text, msg);
  }
}