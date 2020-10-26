import 'dart:typed_data';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/bloc_pattern/chat_box_bloc.dart';
import 'package:moonblink/bloc_pattern/chat_list/chat_list_bloc.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/chat_models/booking_status.dart';
import 'package:moonblink/models/chat_models/new_chat.dart';
import 'package:moonblink/models/chatlist.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/message.dart';

//Production URL
const String proSocketurl = 'https://chat.moonblinkuniverse.com';
const String devSocketUrl = 'http://157.230.35.18:8000/';
const String oldDevSocketUrl = 'http://54.179.117.84/';
String now = DateTime.now().toString();

// List<Message> messages = List<Message>();
List<Files> files = List<Files>();
List<Chatlist> chatlist = List<Chatlist>();
Bookingstatus bookingdata;

class DefaultEvents {
  ///Defaults Events to listen
  static const connect = 'connect';
  static const connectError = 'connect_error';
  static const connectTimeout = 'connect_timeout';
  static const connecting = 'connecting';
  static const disconnect = 'disconnect';
  static const error = 'error';
  static const reconnect = 'reconnect';
  static const reconnectAttempt = 'reconnect_attempt';
  static const reconnectFailed = 'reconnect_failed';
  static const reconnectError = 'reconnect_error';
  static const reconnecting = 'reconnecting';
  static const ping = 'ping';
  static const pong = 'pong';
}

class EventsToEmit {
  static const connectUser = 'connect-user';
  static const chatUpdating = 'chat-updating';
}

class EventsToListen {
  static const connectedUsers = 'connected-users';
  static const conversation = 'conversation';
  static const chatUpdated = 'chat-updated';
}

class WebSocketService {
  ///Singleton pattern
  static final WebSocketService _instance = WebSocketService._();
  factory WebSocketService() => _instance;
  WebSocketService._();

  ChatListBloc _chatListBloc;
  ChatBoxBloc _chatBoxBloc;

  final IO.Socket _socket = IO.io(proSocketurl, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  ///Init when app starts
  void init(ChatListBloc chatListBloc) {
    this._chatListBloc = chatListBloc;
    final userToken = StorageManager.sharedPreferences.getString(token);
    _socket.connect();
    _socket.on(DefaultEvents.connect, (data) {
      print('Web Socket Service - Connected');
      _socket.emit(EventsToEmit.connectUser, userToken);
    });
    _socket.on(EventsToListen.connectedUsers, (data) {
      print('connected-users: $data');
    });
    _socket.on(EventsToListen.conversation, (data) {
      final List<NewChat> chats = [];
      final response = ResponseData.fromJson(data).data as List;
      for(var e in response) {
        chats.add(NewChat.fromJson(e));
      }
      _chatListBloc.chatsSubject.add(chats);
    });
    _socket.on(DefaultEvents.disconnect, (data) => showToast('Disconnected'));
  }

  void initWithChatBoxBloc(ChatBoxBloc chatBoxBloc) {
    this._chatBoxBloc = chatBoxBloc;
    int myId = StorageManager.sharedPreferences.getInt(mUserId);
    _socket.on(EventsToListen.chatUpdated, (data) {
      print('Booking Status: $data');
      final bookingStatus = BookingStatus.fromJson(data);
      _chatBoxBloc.bookingStatusSubject.add(bookingStatus);
    });

    _socket.emit(EventsToEmit.chatUpdating, [
      {'sender_id': myId, 'receiver_id': _chatBoxBloc.partnerId}
    ]);
  }

  void disposeWithChatBoxBloc() {
    this._chatBoxBloc = null;
    _socket.off(EventsToListen.chatUpdated);
  }

  // //Connection Check
  void connection() {
    String usertoken = StorageManager.sharedPreferences.getString(token);
    _socket.on('disconnect', (data) => showToast('Disconnected'));
    _socket.on('reconnect', (data) {
      // showToast('Reconnecting');
      print('reconnecting');
      _socket.emit('connect-user', usertoken);
      showToast('Connected');
    });
  }

  ///[Chating Text]
  //send messages
  void sendMessage(String text, int receiverChatID, List<Message> msg) {
    int userid = StorageManager.sharedPreferences.getInt(mUserId);
    msg.insert(0, Message(text, userid, receiverChatID, now, '', 0));
    print('User ID : $userid');
    print('Receiver ID : $receiverChatID');
    print('Message : $text');
    print('Time : $now');
    _socket.emit('chat-message', [
      {
        'message': text,
        'sender_id': userid,
        'receiver_id': receiverChatID,
        'type': 0
      }
    ]);
  }

  //file message
  void sendfile(String name, Uint8List file, int receiverChatID, int type,
      List<Message> msg) {
    int userid = StorageManager.sharedPreferences.getInt(mUserId);
    String local = new String.fromCharCodes(file);
    msg.insert(0, Message(name, userid, receiverChatID, now, local, 5));
    print('User ID : $userid');
    print('Receiver ID : $receiverChatID');
    print('Name : $name');
    //print('File : ${file.toString()}');
    _socket.emit('upload-attach', [
      {
        'name': name,
        'data': file,
        'sender_id': userid,
        'receiver_id': receiverChatID,
        'media_type': type
      }
    ]);
  }

  //file message
  void sendaudio(String name, Uint8List file, int receiverChatID, int type,
      List<Message> msg, String path) {
    int userid = StorageManager.sharedPreferences.getInt(mUserId);
    // String local = new String.fromCharCodes(file);
    msg.insert(0, Message(name, userid, receiverChatID, now, path, 6));
    print('User ID : $userid');
    print('Receiver ID : $receiverChatID');
    print('Name : $name');
    print('File Path : $path');
    //print('File : ${file.toString()}');
    _socket.emit('upload-attach', [
      {
        'name': name,
        'data': file,
        'sender_id': userid,
        'receiver_id': receiverChatID,
        'media_type': type
      }
    ]);
  }

  //call
  void call(int fromId, int toId, String voiceCallChannelName) {
    print('from ID : $fromId');
    print('to ID : $toId');
    print('channelName : $voiceCallChannelName');
    print('Time : $now');
    _socket.emit('call-user', [
      {'from': fromId, 'to': toId, 'voiceCallChannelName': voiceCallChannelName}
    ]);
  }

  List<Chatlist> conversationlist() {
    print('Getting Chat List');
    _socket.on('conversation', (data) {
      print('----------------------------------------------------');
      print(data.toString());
      chatlist.clear();
      var response = ResponseData.fromJson(data);
      for (var i = 0; i < response.data.length; i++) {
        Chatlist chat = Chatlist.fromMap(response.data[i]);
        chatlist.add(chat);
      }
    });
    return chatlist;
  }

  Bookingstatus chatupdated() {
    _socket.on('chat-updated', (data) {
      bookingdata = Bookingstatus(
          data['booking_id'],
          data['user_id'],
          data['booking_user_id'],
          data['status'],
          data['count'],
          data['created_at'],
          data['updated_at'],
          data['minute_per_section'],
          data['is_block']);
    });

    return bookingdata;
  }

  void updateChat(int receiverId) {
    int userid = StorageManager.sharedPreferences.getInt(mUserId);
    _socket.emit('chat-updating', [
      {'sender_id': userid, 'receiver_id': receiverId}
    ]);
  }

  ///[For receiving message]
  void receiver(List<Message> message, int id) {
    print('Received Messages');
    _socket.clearListeners();
    _socket.on('receiver-peer', (data) {
      if (data['sender_id'] == id || data['receiver_id'] == id) {
        message.insert(
            0,
            Message(data['message'], data['sender_id'], data['receiver_id'],
                data['time'], '', data['type']));
      }
      print('msg added');
    });
    _socket.on('receiver-attach', (data) {
      if (data['sender_id'] == id || data['receiver_id'] == id) {
        message.insert(
            0,
            Message('', data['sender_id'], data['receiver_id'], data['time'],
                data['attach'], data['type']));
      }
    });
  }

  // void receivenoti(int id, String text, String msg) {
  //   PushNotificationsManager().notification(id, text, msg);
  // }

  void disconnect() {
    _socket.disconnect();
    print('Disconnected');
  }
}
