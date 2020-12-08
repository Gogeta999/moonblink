part of 'chat_box_bloc.dart';

abstract class ChatBoxEvent extends Equatable {
  const ChatBoxEvent();
}

class ChatBoxFetched extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}

class ChatBoxFetchedMore extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}

class ChatBoxSendMessage extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}

class ChatBoxSendImage extends ChatBoxEvent {
  final File image;

  ChatBoxSendImage(this.image);

  @override
  List<Object> get props => [image];
}

class ChatBoxSendAudio extends ChatBoxEvent {
  final File audio;

  ChatBoxSendAudio(this.audio);

  @override
  List<Object> get props => [audio];
}

class ChatBoxReceiveMessage extends ChatBoxEvent {
  final String message;
  final int senderId;
  final int receiverId;
  final String time;
  final String attach;
  final int type;

  ChatBoxReceiveMessage(this.message, this.senderId, this.receiverId, this.time,
      this.attach, this.type);

  @override
  List<Object> get props => [message, senderId, receiverId, time, attach, type];
}

class ChatBoxCancelBooking extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}

class ChatBoxCancelBoosting extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}

class ChatBoxEndBooking extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}

class ChatBoxEndBoosting extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}

class ChatBoxCall extends ChatBoxEvent {
  final String channel;
  final int receiverId;

  ChatBoxCall(this.channel, this.receiverId);

  @override
  List<Object> get props => [channel, receiverId];
}

class ChatBoxRejectBooking extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}

class ChatBoxAcceptBooking extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}

class ChatBoxRejectBoosting extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}

class ChatBoxAcceptBoosting extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}

class ChatBoxCheckAvailable extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}

class ChatBoxSecondButton extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}

class ChatBoxThirdButton extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}
