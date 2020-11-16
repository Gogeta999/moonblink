import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moonblink/models/notification_models/user_message_notification.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

part 'user_message_notification_event.dart';
part 'user_message_notification_state.dart';

const int notificationLimit = 10;

class UserMessageNotificationBloc
    extends Bloc<UserMessageNotificationEvent, UserMessageNotificationState> {
  UserMessageNotificationBloc() : super(UserMessageNotificationInitial());

  @override
  Stream<Transition<UserMessageNotificationEvent, UserMessageNotificationState>>
      transformEvents(
          Stream<UserMessageNotificationEvent> events, transitionFn) {
    return super.transformEvents(
        events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
  }

  void dispose() {
    this.close();
  }

  @override
  Stream<UserMessageNotificationState> mapEventToState(
    UserMessageNotificationEvent event,
  ) async* {
    final currentState = state;
    if (event is UserMessageNotificationFetched &&
        !_hasReachedMax(currentState)) {
      yield* _mapFetchedToState(currentState);
    }
    if (event is UserMessageNotificationRefreshed) {
      yield* _mapRefreshedToState(currentState);
    }
    if (event is UserMessageNotificationCleared) {
      yield* _mapClearedToState(currentState);
    }
  }

  ///Initial Fetched
  Stream<UserMessageNotificationState> _mapFetchedToState(
      UserMessageNotificationState currentState) async* {
    if (currentState is UserMessageNotificationInitial) {
      List<UserMessageNotificationData> data = [];
      try {
        data = await _fetchUserNotification(limit: notificationLimit, page: 1);
      } catch (e) {
        yield UserMessageNotificationFailure(error: e);
        return;
      }
      bool hasReachedMax = data.length < notificationLimit ? true : false;
      yield UserMessageNotificationSuccess(
          data: data, hasReachedMax: hasReachedMax, page: 1);
    }
    if (currentState is UserMessageNotificationSuccess) {
      final nextPage = currentState.page + 1;
      List<UserMessageNotificationData> data = [];
      try {
        data = await _fetchUserNotification(
            limit: notificationLimit, page: nextPage);
      } catch (error) {
        print(error);
        //yield UserMessageNotificationFailure(error: error);
      }
      bool hasReachedMax = data.length < notificationLimit ? true : false;
      yield data.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : UserMessageNotificationSuccess(
              data: currentState.data + data,
              hasReachedMax: hasReachedMax,
              page: nextPage);
    }
  }

  ///Refreshing page 1
  Stream<UserMessageNotificationState> _mapRefreshedToState(
      UserMessageNotificationState currentState) async* {
    List<UserMessageNotificationData> data = [];
    try {
      data = await _fetchUserNotification(limit: notificationLimit, page: 1);
    } catch (error) {
      yield UserMessageNotificationFailure(error: error);
      return;
    }
    bool hasReachedMax = data.length < notificationLimit ? true : false;
    yield UserMessageNotificationSuccess(
        data: data, hasReachedMax: hasReachedMax, page: 1);
  }

  ///ResetState
  Stream<UserMessageNotificationState> _mapClearedToState(
      UserMessageNotificationState currentState) async* {
    yield UserMessageNotificationInitial();
  }

  bool _hasReachedMax(UserMessageNotificationState state) =>
      state is UserMessageNotificationSuccess && state.hasReachedMax;

  Future<List<UserMessageNotificationData>> _fetchUserNotification(
      {int limit, int page}) async {
    UserMessageNotificationResponse data =
        await MoonBlinkRepository.getUserMessageNotifications(limit, page);
    return data.data;
  }
}
