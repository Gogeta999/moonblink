import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/models/chat_models/new_chat.dart';
import 'package:moonblink/services/web_socket_service.dart';
import 'package:rxdart/rxdart.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

///The simplest bloc xD
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  ChatListBloc() : super(ChatListInitial());

  final scrollController = ScrollController();
  double scrollThreshold = 400.0;
  Timer _debounce;
  final limit = 5;
  int nextPage = 1;
  bool hasReachedMax = false;
  bool isFetching = false;

  final chatsSubject = BehaviorSubject.seeded(<NewChat>[]);

  void dispose() {
    _debounce?.cancel();
    chatsSubject.close();
  }

  void onScroll() {
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= scrollThreshold) {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (isFetching) return;
        if (hasReachedMax) return;
        isFetching = true;
        fetchChats();

        ///this.fetchMoreData(); Send Socket Upadte event
      });
    }
  }

  void fetchChats() {
    WebSocketService().updateConversation();
  }

  @override
  Stream<ChatListState> mapEventToState(ChatListEvent event) async* {}
}
