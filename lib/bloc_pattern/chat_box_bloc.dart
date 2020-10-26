import 'dart:async';
import 'dart:html';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/chat_models/booking_status.dart';
import 'package:moonblink/models/chat_models/last_message.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:rxdart/rxdart.dart';

part 'chat_box_event.dart';
part 'chat_box_state.dart';

const int _limit = 20;

class ChatBoxBloc extends Bloc<ChatBoxEvent, ChatBoxState> {
  ChatBoxBloc(this.partnerId) : super(ChatBoxInitial());

  final int partnerId; /// it's also other user id
  final int myId = StorageManager.sharedPreferences.getInt(mUserId);

  final bookingStatusSubject =  BehaviorSubject<BookingStatus>();

  ///Button State
  final bookingCancelButtonSubject = BehaviorSubject.seeded(false);

  @override
  Stream<Transition<ChatBoxEvent, ChatBoxState>> transformEvents(
      Stream<ChatBoxEvent> events, transitionFn) {
    return super.transformEvents(
        events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
  }

  @override
  Stream<ChatBoxState> mapEventToState(
      ChatBoxEvent event,
      ) async* {
    final currentState = state;
    if (event is ChatBoxFetched && !_hasReachedMax(currentState)) {
      yield* _mapFetchedToState(currentState);
    }
    if (event is ChatBoxCancelBooking) yield* _mapCancelBookingToState(event.bookingId);
  }

  Stream<ChatBoxState> _mapFetchedToState(
      ChatBoxState currentState) async* {
    if (currentState is ChatBoxInitial) {
      List<LastMessage> data = [];
      PartnerUser partnerUser;
      try {
        List<Future> futures = [_fetchLastMessages(limit: _limit, page: 1),
          MoonBlinkRepository.fetchPartner(partnerId)];
        final results = await Future.wait(futures, eagerError: true);
        data = results.first;
        partnerUser = results.last;
      } catch (e) {
        yield ChatBoxFailure(error: e);
        return;
      }
      bool hasReachedMax = data.length < _limit ? true : false;
      yield ChatBoxSuccess(partnerUser: partnerUser,
          data: data, hasReachedMax: hasReachedMax, page: 1);
    }
    if (currentState is ChatBoxSuccess) {
      final nextPage = currentState.page + 1;
      List<LastMessage> data = [];
      try {
        data = await _fetchLastMessages(limit: _limit, page: nextPage);
      } catch (error) {
        yield ChatBoxFailure(error: error);
      }
      bool hasReachedMax = data.length < _limit ? true : false;
      yield data.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : ChatBoxSuccess(
          partnerUser: currentState.partnerUser,
          data: currentState.data + data,
          hasReachedMax: hasReachedMax,
          page: nextPage);
    }
  }

  Stream<ChatBoxState> _mapCancelBookingToState(int bookingId) async* {
    try {
      bookingCancelButtonSubject.add(true);
      await MoonBlinkRepository.endbooking(myId, bookingId, CANCEL);
      yield ChatBoxCancelBookingSuccess();
      bookingCancelButtonSubject.add(false);
    } catch (e) {
      yield ChatBoxCancelBookingFailure(e);
      bookingCancelButtonSubject.add(false);
    }
  }

  bool _hasReachedMax(ChatBoxState state) =>
      state is ChatBoxSuccess && state.hasReachedMax;

  Future<List<LastMessage>> _fetchLastMessages({int limit, int page}) async {
    return await MoonBlinkRepository.getLastMessages(id: partnerId, limit: limit, page: page);
  }
}
