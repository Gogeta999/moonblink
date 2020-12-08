part of 'chat_box_bloc.dart';

abstract class ChatBoxState extends Equatable {
  const ChatBoxState();
}

class ChatBoxInitial extends ChatBoxState {
  @override
  List<Object> get props => [];
}

class ChatBoxFailure extends ChatBoxState {
  final error;

  const ChatBoxFailure({this.error});

  @override
  List<Object> get props => [error];
}

class ChatBoxSuccess extends ChatBoxState {
  final List<LastMessage> data;
  final bool hasReachedMax;
  final int page;

  const ChatBoxSuccess({this.data, this.hasReachedMax, this.page});

  ChatBoxSuccess copyWith(
      {List<LastMessage> data, bool hasReachedMax, int page}) {
    return ChatBoxSuccess(
        data: data ?? this.data,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        page: page ?? this.page);
  }

  @override
  List<Object> get props => [data, hasReachedMax, page];

  @override
  String toString() =>
      'ChatBoxSuccess: ${data.length}, hasReachedMax: $hasReachedMax';
}

class ChatBoxCancelBookingSuccess extends ChatBoxState {
  @override
  List<Object> get props => [];
}

class ChatBoxCancelBookingFailure extends ChatBoxState {
  final error;

  ChatBoxCancelBookingFailure(this.error);

  @override
  List<Object> get props => [error];
}

class ChatBoxCancelBoostingSuccess extends ChatBoxState {
  @override
  List<Object> get props => [];
}

class ChatBoxCancelBoostingFailure extends ChatBoxState {
  final error;

  ChatBoxCancelBoostingFailure(this.error);

  @override
  List<Object> get props => [error];
}

class ChatBoxCallSuccess extends ChatBoxState {
  final String channel;

  ChatBoxCallSuccess(this.channel);

  @override
  List<Object> get props => [channel];
}

class ChatBoxCallFailure extends ChatBoxState {
  final error;

  ChatBoxCallFailure(this.error);

  @override
  List<Object> get props => [error];
}

class ChatBoxEndBookingSuccess extends ChatBoxState {
  @override
  List<Object> get props => [];
}

class ChatBoxEndBookingFailure extends ChatBoxState {
  final error;

  ChatBoxEndBookingFailure(this.error);

  @override
  List<Object> get props => [error];
}

class ChatBoxEndBoostingSuccess extends ChatBoxState {
  @override
  List<Object> get props => [];
}

class ChatBoxEndBoostingFailure extends ChatBoxState {
  final error;

  ChatBoxEndBoostingFailure(this.error);

  @override
  List<Object> get props => [error];
}

class ChatBoxRejectBookingSuccess extends ChatBoxState {
  @override
  List<Object> get props => [];
}

class ChatBoxRejectBookingFailure extends ChatBoxState {
  final error;

  ChatBoxRejectBookingFailure(this.error);

  @override
  List<Object> get props => [error];
}

class ChatBoxRejectBoostingSuccess extends ChatBoxState {
  @override
  List<Object> get props => [];
}

class ChatBoxRejectBoostingFailure extends ChatBoxState {
  final error;

  ChatBoxRejectBoostingFailure(this.error);

  @override
  List<Object> get props => [error];
}

class ChatBoxAcceptBookingSuccess extends ChatBoxState {
  @override
  List<Object> get props => [];
}

class ChatBoxAcceptBookingFailure extends ChatBoxState {
  final error;

  ChatBoxAcceptBookingFailure(this.error);

  @override
  List<Object> get props => [error];
}

class ChatBoxAcceptBoostingSuccess extends ChatBoxState {
  @override
  List<Object> get props => [];
}

class ChatBoxAcceptBoostingFailure extends ChatBoxState {
  final error;

  ChatBoxAcceptBoostingFailure(this.error);

  @override
  List<Object> get props => [error];
}
