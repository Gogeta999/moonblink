import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moonblink/models/chat_models/new_chat.dart';
import 'package:rxdart/rxdart.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

const int _limit = 5;

///The simplest bloc xD
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {

  ChatListBloc() : super(ChatListInitial());

  final chatsSubject = BehaviorSubject.seeded(<NewChat>[]);

  @override
  Stream<ChatListState> mapEventToState(ChatListEvent event) async* {

  }
}

/*

  ChatListBloc() : super(ChatListInitial());

  @override
  Stream<Transition<ChatListEvent, ChatListState>> transformEvents(
      Stream<ChatListEvent> events, transitionFn) {
    return super.transformEvents(
        events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
  }

  @override
  Stream<ChatListState> mapEventToState(
      ChatListEvent event,
      ) async* {
    final currentState = state;
    if (event is ChatListFetched && !_hasReachedMax(currentState)) {
      yield* _mapFetchedToState(currentState);
    }
    if (event is ChatListRefreshed) {
      yield* _mapRefreshedToState(currentState);
    }
  }

  Stream<ChatListState> _mapFetchedToState(
      ChatListState currentState) async* {
    if (currentState is ChatListInitial) {
      List<NewChat> data = [];
      try {
        data = await _fetchChatList(limit: _limit, page: 1);
      } catch (e) {
        yield ChatListFailure(error: e);
        return;
      }
      bool hasReachedMax = data.length < _limit ? true : false;
      yield ChatListSuccess(
          data: data, hasReachedMax: hasReachedMax, page: 1);
    }
    if (currentState is ChatListSuccess) {
      final nextPage = currentState.page + 1;
      List<NewChat> data = [];
      try {
        data = await _fetchChatList(limit: _limit, page: nextPage);
      } catch (error) {
        yield ChatListFailure(error: error);
      }
      bool hasReachedMax = data.length < _limit ? true : false;
      yield data.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : ChatListSuccess(
          data: currentState.data + data,
          hasReachedMax: hasReachedMax,
          page: nextPage);
    }
  }

  Stream<ChatListState> _mapRefreshedToState(
      ChatListState currentState) async* {
    List<NewChat> data = [];
    yield ChatListRefreshing();
    try {
      data = await _fetchChatList(limit: _limit, page: 1);
    } catch (error) {
      yield ChatListFailure(error: error);
      return;
    }
    bool hasReachedMax = data.length < _limit ? true : false;
    yield data.isEmpty
        ? ChatListNoData()
        : ChatListSuccess(data: data, hasReachedMax: hasReachedMax, page: 1);
  }

  bool _hasReachedMax(ChatListState state) =>
      state is ChatListSuccess && state.hasReachedMax;

  ///limit and page don't need for now
  Future<List<NewChat>> _fetchChatList({int limit, int page}) async {

  }*/