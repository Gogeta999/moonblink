part of 'chat_list_bloc.dart';

abstract class ChatListState extends Equatable {
  const ChatListState();
}

class ChatListInitial extends ChatListState {
  @override
  List<Object> get props => [];
}

class ChatListFailure extends ChatListState {
  final error;

  const ChatListFailure({this.error});

  @override
  List<Object> get props => [error];

}

class ChatListNoData extends ChatListState {
  @override
  List<Object> get props => [];

}

class ChatListRefreshing extends ChatListState {
  @override
  List<Object> get props => [];

}

class ChatListSuccess extends ChatListState {
  final List<NewChat> data;
  final bool hasReachedMax;
  final int page;

  const ChatListSuccess({this.data, this.hasReachedMax, this.page});

  ChatListSuccess copyWith({List<NewChat> data, bool hasReachedMax, int page}) {
    return ChatListSuccess(
        data: data ?? this.data,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        page: page ?? this.page
    );
  }

  @override
  List<Object> get props => [data, hasReachedMax];

  @override
  String toString() => 'ChatListSuccess: ${data.length}, hasReachedMax: $hasReachedMax';
}