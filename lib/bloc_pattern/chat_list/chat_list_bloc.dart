import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moonblink/models/chat_models/new_chat.dart';
import 'package:rxdart/rxdart.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

///The simplest bloc xD
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {

  ChatListBloc() : super(ChatListInitial());

  // ignore: close_sinks
  final chatsSubject = BehaviorSubject.seeded(<NewChat>[]);

  @override
  Stream<ChatListState> mapEventToState(ChatListEvent event) async* {

  }
}