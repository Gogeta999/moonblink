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
  final PartnerUser partnerUser;
  final List<LastMessage> data;
  final bool hasReachedMax;
  final int page;

  const ChatBoxSuccess(
      {this.partnerUser, this.data, this.hasReachedMax, this.page});

  ChatBoxSuccess copyWith(
      {PartnerUser partnerUser,
      List<LastMessage> data,
      bool hasReachedMax,
      int page}) {
    return ChatBoxSuccess(
        partnerUser: partnerUser ?? this.partnerUser,
        data: data ?? this.data,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        page: page ?? this.page);
  }

  @override
  List<Object> get props => [partnerUser, data, hasReachedMax, page];

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
