part of 'chat_box_bloc.dart';

abstract class ChatBoxEvent extends Equatable {
  const ChatBoxEvent();
}

class ChatBoxFetched extends ChatBoxEvent {
  @override
  List<Object> get props => [];
}

class ChatBoxCancelBooking extends ChatBoxEvent {
  final int bookingId;

  ChatBoxCancelBooking(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

class ChatBoxCall extends ChatBoxEvent {
  final String channel;
  final int receiverId;

  ChatBoxCall(this.channel, this.receiverId);

  @override
  List<Object> get props => [channel, receiverId];

}