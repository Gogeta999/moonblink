part of 'chat_list_bloc.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();
}

class ChatListFetched extends ChatListEvent {
  @override
  List<Object> get props => [];
}

class ChatListRefreshed extends ChatListEvent {
  @override
  List<Object> get props => [];
}