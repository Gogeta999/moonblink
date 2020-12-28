import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moonblink/models/notification_models/user_booking_notification.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'user_booking_notification_event.dart';
part 'user_booking_notification_state.dart';

const int notificationLimit = 10;

class UserBookingNotificationBloc
    extends Bloc<UserBookingNotificationEvent, UserBookingNotificationState> {
  UserBookingNotificationBloc() : super(UserBookingNotificationInitial());

  @override
  Stream<Transition<UserBookingNotificationEvent, UserBookingNotificationState>>
      transformEvents(
          Stream<UserBookingNotificationEvent> events, transitionFn) {
    return super.transformEvents(
        events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
  }

  void dispose() {
    this.close();
  }

  @override
  Stream<UserBookingNotificationState> mapEventToState(
    UserBookingNotificationEvent event,
  ) async* {
    final currentState = state;
    if (event is UserBookingNotificationFetched &&
        !_hasReachedMax(currentState)) {
      yield* _mapFetchedToState(currentState);
    }
    if (event is UserBookingNotificationRefreshed) {
      yield* _mapRefreshedToState(currentState);
    }
    if (event is UserBookingNotificationCleared) {
      yield* _mapClearedToState(currentState);
    }
  }

  ///Initial Fetched
  Stream<UserBookingNotificationState> _mapFetchedToState(
      UserBookingNotificationState currentState) async* {
    if (currentState is UserBookingNotificationInitial ||
        currentState is UserBookingNotificationFailure) {
      List<UserBookingNotificationData> data = [];
      try {
        data = await _fetchUserNotification(limit: notificationLimit, page: 1);
      } catch (e) {
        yield UserBookingNotificationFailure(error: e);
        return;
      }
      bool hasReachedMax = data.length < notificationLimit ? true : false;
      yield UserBookingNotificationSuccess(
          data: data, hasReachedMax: hasReachedMax, page: 1);
    }
    if (currentState is UserBookingNotificationSuccess) {
      final nextPage = currentState.page + 1;
      List<UserBookingNotificationData> data = [];
      try {
        data = await _fetchUserNotification(
            limit: notificationLimit, page: nextPage);
      } catch (error) {
        yield UserBookingNotificationFailure(error: error);
        return;
      }
      bool hasReachedMax = data.length < notificationLimit ? true : false;
      yield data.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : UserBookingNotificationSuccess(
              data: currentState.data + data,
              hasReachedMax: hasReachedMax,
              page: nextPage);
    }
  }

  ///Refreshing page 1
  Stream<UserBookingNotificationState> _mapRefreshedToState(
      UserBookingNotificationState currentState) async* {
    List<UserBookingNotificationData> data = [];
    try {
      data = await _fetchUserNotification(limit: notificationLimit, page: 1);
    } catch (error) {
      yield UserBookingNotificationFailure(error: error);
      return;
    }
    bool hasReachedMax = data.length < notificationLimit ? true : false;
    yield UserBookingNotificationSuccess(
        data: data, hasReachedMax: hasReachedMax, page: 1);
  }

  ///ResetState
  Stream<UserBookingNotificationState> _mapClearedToState(
      UserBookingNotificationState currentState) async* {
    yield UserBookingNotificationInitial();
  }

  bool _hasReachedMax(UserBookingNotificationState state) =>
      state is UserBookingNotificationSuccess && state.hasReachedMax;

  Future<List<UserBookingNotificationData>> _fetchUserNotification(
      {int limit, int page}) async {
    UserBookingNotificationResponse data =
        await MoonBlinkRepository.getUserBookingNotifications(limit, page);
    return data.data;
  }
}
