import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/chat_models/booking_status.dart';
import 'package:moonblink/models/chat_models/last_message.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:moonblink/services/web_socket_service.dart';
import 'package:intl/intl.dart';

part 'chat_box_event.dart';
part 'chat_box_state.dart';

const int _limit = 30;

class ChatBoxBloc extends Bloc<ChatBoxEvent, ChatBoxState> {
  ChatBoxBloc(this.partnerId) : super(ChatBoxInitial());

  bool _isFetching = false;

  final int partnerId;

  /// it's also other user id
  final int myId = StorageManager.sharedPreferences.getInt(mUserId);

  final bookingStatusSubject = BehaviorSubject<BookingStatus>.seeded(null);

  ///Button State
  final bookingCancelButtonSubject = BehaviorSubject.seeded(false);
  final callButtonSubject = BehaviorSubject.seeded(false);
  final rejectButtonSubject = BehaviorSubject.seeded(false);
  final acceptButtonSubject = BehaviorSubject.seeded(false);

  final TextEditingController messageController = TextEditingController();

  @override
  Stream<ChatBoxState> mapEventToState(
    ChatBoxEvent event,
  ) async* {
    final currentState = state;
    if (event is ChatBoxFetched && !_hasReachedMax(currentState)) {
      yield* _mapFetchedToState(currentState);
    }
    if (event is ChatBoxCancelBooking)
      yield* _mapCancelBookingToState(currentState);
    if (event is ChatBoxCall)
      yield* _mapCallToState(currentState, event.channel, event.receiverId);
    if (event is ChatBoxEndBooking) yield* _mapEndBookingToState(currentState);
    if (event is ChatBoxRejectBooking)
      yield* _mapRejectBookingToState(currentState);
    if (event is ChatBoxAcceptBooking)
      yield* _mapAcceptBookingToState(currentState);
    if (event is ChatBoxSendMessage)
      yield* _mapSendMessageToState(currentState);
    if (event is ChatBoxReceiveMessage)
      yield* _mapReceiveMessageToState(
          currentState,
          event.message,
          event.senderId,
          event.receiverId,
          event.time,
          event.attach,
          event.type);
  }

  Stream<ChatBoxState> _mapFetchedToState(ChatBoxState currentState) async* {
    if (currentState is ChatBoxInitial) {
      List<LastMessage> data = [];
      PartnerUser partnerUser;
      try {
        List<Future> futures = [
          _fetchLastMessages(limit: _limit, page: 1),
          MoonBlinkRepository.fetchPartner(partnerId)
        ];
        final results = await Future.wait(futures, eagerError: true);
        data = results.first;
        partnerUser = results.last;
      } catch (e) {
        yield ChatBoxFailure(error: e);
        return;
      }
      bool hasReachedMax = data.length < _limit ? true : false;
      yield ChatBoxSuccess(
          partnerUser: partnerUser,
          data: data,
          hasReachedMax: hasReachedMax,
          page: 1);
    }
    if (currentState is ChatBoxSuccess) {
      if (_isFetching) return;
      _isFetching = true;
      final nextPage = currentState.page + 1;
      List<LastMessage> data = [];
      try {
        data = await _fetchLastMessages(limit: _limit, page: nextPage);
      } catch (error) {
        yield ChatBoxFailure(error: error);
      }
      bool hasReachedMax = data.length < _limit ? true : false;
      _isFetching = false;
      yield data.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : ChatBoxSuccess(
              partnerUser: currentState.partnerUser,
              data: currentState.data + data,
              hasReachedMax: hasReachedMax,
              page: nextPage);
    }
  }

  Stream<ChatBoxState> _mapCancelBookingToState(
      ChatBoxState currentState) async* {
    if (currentState is ChatBoxSuccess) {
      try {
        bookingCancelButtonSubject.add(true);
        final bookingStatus = await bookingStatusSubject.first;
        await MoonBlinkRepository.endbooking(
            myId, bookingStatus.bookingId, CANCEL);
        yield ChatBoxCancelBookingSuccess();
        bookingCancelButtonSubject.add(false);
        yield currentState.copyWith();
      } catch (e) {
        yield ChatBoxCancelBookingFailure(e);
        bookingCancelButtonSubject.add(false);
        yield currentState.copyWith();
      }
    }
  }

  Stream<ChatBoxState> _mapEndBookingToState(ChatBoxState currentState) async* {
    if (currentState is ChatBoxSuccess) {
      try {
        final bookingStatus = await bookingStatusSubject.first;
        await MoonBlinkRepository.endbooking(
            myId, bookingStatus.bookingId, DONE);
        yield ChatBoxEndBookingSuccess();
        yield currentState.copyWith();
      } catch (e) {
        yield ChatBoxEndBookingFailure(e);
        yield currentState.copyWith();
      }
    }
  }

  Stream<ChatBoxState> _mapRejectBookingToState(
      ChatBoxState currentState) async* {
    if (currentState is ChatBoxSuccess) {
      try {
        rejectButtonSubject.add(true);
        final bookingStatus = await bookingStatusSubject.first;
        await MoonBlinkRepository.bookingAcceptOrDecline(
            myId, bookingStatus.bookingId, REJECT);
        yield ChatBoxRejectBookingSuccess();
        rejectButtonSubject.add(false);
        yield currentState.copyWith();
      } catch (e) {
        yield ChatBoxRejectBookingFailure(e);
        rejectButtonSubject.add(false);
        yield currentState.copyWith();
      }
    }
  }

  Stream<ChatBoxState> _mapAcceptBookingToState(
      ChatBoxState currentState) async* {
    if (currentState is ChatBoxSuccess) {
      try {
        acceptButtonSubject.add(true);
        final bookingStatus = await bookingStatusSubject.first;
        await MoonBlinkRepository.bookingAcceptOrDecline(
            myId, bookingStatus.bookingId, ACCEPTED);
        yield ChatBoxAcceptBookingSuccess();
        acceptButtonSubject.add(false);
        yield currentState.copyWith();
      } catch (e) {
        yield ChatBoxAcceptBookingFailure(e);
        acceptButtonSubject.add(false);
        yield currentState.copyWith();
      }
    }
  }

  Stream<ChatBoxState> _mapCallToState(
      ChatBoxState currentState, String channel, int id) async* {
    if (currentState is ChatBoxSuccess) {
      try {
        callButtonSubject.add(true);
        await MoonBlinkRepository.call(channel, id);
        yield ChatBoxCallSuccess(channel);
        callButtonSubject.add(false);
        yield currentState.copyWith();
      } catch (e) {
        yield ChatBoxCallFailure(e);
        callButtonSubject.add(false);
        yield currentState.copyWith();
      }
    }
  }

  Stream<ChatBoxState> _mapSendMessageToState(
      ChatBoxState currentState) async* {
    if (currentState is ChatBoxSuccess && messageController.text.isNotEmpty) {
      final text = messageController.text;
      messageController.clear();
      WebSocketService().sendMessage(text, partnerId);
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      final now = dateFormat.format(DateTime.now());
      final id = currentState.data.last.id + 1;
      final roomId = currentState.data.last.roomId;
      final senderId = myId;
      final receiverId = partnerId;
      final newMessage = text;
      final type = MESSAGE;
      final attach = '';
      final createdAt = now;
      final updatedAt = now;
      final lastMessage = LastMessage(id, roomId, senderId, receiverId,
          newMessage, type, attach, createdAt, updatedAt);
      final List<LastMessage> data = List.from(currentState.data);
      data.insert(0, lastMessage);
      yield currentState.copyWith(data: data);
    }
  }

  Stream<ChatBoxState> _mapReceiveMessageToState(
      ChatBoxState currentState,
      String message,
      int senderId,
      int receiverId,
      String time,
      String attach,
      int type) async* {
    if (currentState is ChatBoxSuccess) {
      final id = currentState.data.last.id + 1;
      final roomId = currentState.data.last.roomId;
      final lastMessage = LastMessage(
          id, roomId, senderId, receiverId, message, type, attach, time, time);
      final List<LastMessage> data = List.from(currentState.data);
      data.insert(0, lastMessage);
      yield currentState.copyWith(data: data);
    }
  }

  bool _hasReachedMax(ChatBoxState state) =>
      state is ChatBoxSuccess && state.hasReachedMax;

  Future<List<LastMessage>> _fetchLastMessages({int limit, int page}) async {
    return await MoonBlinkRepository.getLastMessages(
        id: partnerId, limit: limit, page: page);
  }
}
