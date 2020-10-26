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

  ChatBoxCancelBooking(this.bookingId)


  @override
  List<Object> get props => [bookingId];
}