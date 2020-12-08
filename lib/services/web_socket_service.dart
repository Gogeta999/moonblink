import 'dart:typed_data';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/bloc_pattern/chat_box/chat_box_bloc.dart';
import 'package:moonblink/bloc_pattern/chat_list/chat_list_bloc.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/chat_models/booking_status.dart';
import 'package:moonblink/models/chat_models/last_boost_order.dart';
import 'package:moonblink/models/chat_models/new_chat.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

//Production URL
const String proSocketurl = 'https://chat.moonblinkuniverse.com';
const String devSocketUrl = 'http://157.230.35.18:8000/';
const String oldDevSocketUrl = 'http://54.179.117.84/';

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
  static const chatMessage = 'chat-message';
  static const callUser = 'call-user';
  static const uploadAttach = 'upload-attach';
}

class EventsToListen {
  static const connectedUsers = 'connected-users';
  static const conversation = 'conversation';
  static const chatUpdated = 'chat-updated';
  static const receiveMessage = 'receiver-peer';
  static const receiveAttach = 'receiver-attach';
  static const sendLastBoostOrder = 'send-last-boost-order';
}

class WebSocketService {
  ///Singleton pattern
  static final WebSocketService _instance = WebSocketService._();
  factory WebSocketService() => _instance;
  WebSocketService._();

  ChatListBloc _chatListBloc;
  ChatBoxBloc _chatBoxBloc;

  final IO.Socket _socket = IO.io(devSocketUrl, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
    'timeout': 2000
  });

  ///Init when app starts
  void init(ChatListBloc chatListBloc) {
    this._chatListBloc = chatListBloc;
    final userToken = StorageManager.sharedPreferences.getString(token);

    ///Register events
    _socket.on(DefaultEvents.connect, (data) {
      print('Web Socket Service - Connected');
      _socket.emit(EventsToEmit.connectUser, userToken);
      _chatBoxBloc?.add(
          ChatBoxFetched()); //if user is in chatbox then reconnecting will fetch data from server again.
      showToast('Connected');
    });
    _socket.on(DefaultEvents.connectError, (data) {
      print('Web Socket Service - Connect Error $data');
    });
    _socket.on(DefaultEvents.connectTimeout, (data) {
      print('Web Socket Service - ConnectTimeout $data');
    });
    _socket.on(DefaultEvents.connecting, (data) {
      print('Web Socket Service - Connecting $data');
    });
    _socket.once(EventsToListen.connectedUsers, (data) {
      print('Connected Users: $data');
    });

    _socket.on(DefaultEvents.disconnect, (data) => showToast('Disconnected'));

    ///Socket connect
    _socket.connect();
    _socket.on(EventsToListen.conversation, (data) {
      final List<NewChat> chats = [];
      final response = ResponseData.fromJson(data).data as List;
      for (var e in response) {
        chats.add(NewChat.fromJson(e));
      }
      _chatListBloc.chatsSubject.add(chats);
    });
  }

  void initWithChatBoxBloc(ChatBoxBloc chatBoxBloc) {
    this._chatBoxBloc = chatBoxBloc;
    _socket.on(EventsToListen.chatUpdated, (data) {
      print('Booking Status: $data');
      final bookingStatus = BookingStatus.fromJson(data);
      _chatBoxBloc.bookingStatusSubject.add(bookingStatus);
    });
    _socket.on(EventsToListen.sendLastBoostOrder, (data) {
      print('Last Boost Order: $data');
      final lastBoostOrder = LastBoostOrder.fromJson(data);
      _chatBoxBloc.boostingStatusSubject.add(lastBoostOrder);
    });

    updateChat();

    _socket.on(EventsToListen.receiveMessage, (data) {
      _chatBoxBloc.add(ChatBoxReceiveMessage(data['message'], data['sender_id'],
          data['receiver_id'], data['time'], '', data['type']));
    });
    _socket.on(EventsToListen.receiveAttach, (data) {
      _chatBoxBloc.add(ChatBoxReceiveMessage('', data['sender_id'],
          data['receiver_id'], data['time'], data['attach'], data['type']));
    });
  }

  void updateChat() {
    final myId = StorageManager.sharedPreferences.getInt(mUserId);
    _socket.emit(EventsToEmit.chatUpdating, [
      {'sender_id': myId, 'receiver_id': _chatBoxBloc.partnerId}
    ]);
  }

  void sendMessage(String message, int receiverId) {
    final int myId = StorageManager.sharedPreferences.getInt(mUserId);
    print('Message Sent - $message');
    _socket.emit(EventsToEmit.chatMessage, [
      {
        'message': message,
        'sender_id': myId,
        'receiver_id': receiverId,
        'type': MESSAGE
      }
    ]);
  }

  void sendImage(String fileName, Uint8List file, int receiverId) {
    final int myId = StorageManager.sharedPreferences.getInt(mUserId);
    _socket.emit(EventsToEmit.uploadAttach, [
      {
        'name': fileName,
        'data': file,
        'sender_id': myId,
        'receiver_id': receiverId,
        'media_type': IMAGE
      }
    ]);
  }

  void sendAudio(String fileName, Uint8List file, int receiverId) {
    final int myId = StorageManager.sharedPreferences.getInt(mUserId);
    _socket.emit(EventsToEmit.uploadAttach, [
      {
        'name': fileName,
        'data': file,
        'sender_id': myId,
        'receiver_id': receiverId,
        'media_type': AUDIO
      }
    ]);
  }

  void disposeWithChatBoxBloc() {
    this._chatBoxBloc = null;
    _socket.off(EventsToListen.chatUpdated);
    _socket.off(EventsToListen.sendLastBoostOrder);
    _socket.off(EventsToListen.receiveAttach);
    _socket.off(EventsToListen.receiveMessage);
  }

  ///Not Using
  // void call(int fromId, int toId, String voiceCallChannelName) {
  //   print('from ID : $fromId');
  //   print('to ID : $toId');
  //   print('channelName : $voiceCallChannelName');
  //   print('Time : $now');
  //   _socket.emit('call-user', [
  //     {'from': fromId, 'to': toId, 'voiceCallChannelName': voiceCallChannelName}
  //   ]);
  // }

  void dispose() {
    _socket.dispose();
  }
}
