import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/booking/booking_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/user_notification.dart';
import 'package:moonblink/models/user_rating.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

part 'user_notification_event.dart';
part 'user_notification_state.dart';

const int notificationLimit = 20;

class UserNotificationBloc
    extends Bloc<UserNotificationEvent, UserNotificationState> {
  UserNotificationBloc() : super(UserNotificationInitial());

  @override
  Stream<Transition<UserNotificationEvent, UserNotificationState>>
      transformEvents(Stream<UserNotificationEvent> events, transitionFn) {
    return super.transformEvents(
        events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
  }

  @override
  Stream<UserNotificationState> mapEventToState(
    UserNotificationEvent event,
  ) async* {
    final currentState = state;
    if (event is UserNotificationFetched && !_hasReachedMax(currentState)) {
      yield* _mapFetchedToState(currentState);
    }
    if (event is UserNotificationRefreshed) {
      yield* _mapRefreshedToState(currentState);
    }
    if (event is UserNotificationAccepted) {
      yield* _mapAcceptedToState(currentState, event.userId, event.bookingUserId);
    }
    if (event is UserNotificationRejected) {
      yield* _mapRejectedToState(currentState, event.userId, event.bookingUserId);
    }
  }

  Stream<UserNotificationState> _mapFetchedToState(
      UserNotificationState currentState) async* {
    if (currentState is UserNotificationInitial) {
      List<UserNotificationData> data = [];
      try {
        data = await _fetchUserNotification(limit: notificationLimit, page: 1);
      } catch (e) {
        yield UserNotificationFailure(error: e);
        return;
      }
      bool hasReachedMax = data.length < notificationLimit ? true : false;
      yield UserNotificationSuccess(
          data: data, hasReachedMax: hasReachedMax, page: 1);
    }
    if (currentState is UserNotificationSuccess) {
      final nextPage = currentState.page + 1;
      List<UserNotificationData> data = [];
      try {
        data = await _fetchUserNotification(
            limit: notificationLimit, page: nextPage);
      } catch (error) {
        yield UserNotificationFailure(error: error);
      }
      bool hasReachedMax = data.length < notificationLimit ? true : false;
      yield data.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : UserNotificationSuccess(
              data: currentState.data + data,
              hasReachedMax: hasReachedMax,
              page: nextPage);
    }
  }

  Stream<UserNotificationState> _mapRefreshedToState(
      UserNotificationState currentState) async* {
    List<UserNotificationData> data = [];
    try {
      data = await _fetchUserNotification(limit: notificationLimit, page: 1);
    } catch (error) {
      yield UserNotificationFailure(error: error);
      return;
    }
    bool hasReachedMax = data.length < notificationLimit ? true : false;
    yield data.isEmpty
        ? UserNotificationNoData()
        : UserNotificationSuccess(
            data: data, hasReachedMax: hasReachedMax, page: 1);
  }
  
  Stream<UserNotificationState> _mapAcceptedToState(
      UserNotificationState currentState, int userId, int bookingId) async* {
    try {
      await MoonBlinkRepository.bookingAcceptOrDecline(userId, bookingId, BOOKING_ACCEPT).then((value) =>
      value != null
          ? locator<NavigationService>()
          .navigateTo(RouteName.chatBox, arguments: bookingId)
          : null);
      showToast('Booking Accepted');
    } catch (error) {
      showToast('$error');
      print('Error $error');
      return;
    }
  }

  Stream<UserNotificationState> _mapRejectedToState(
      UserNotificationState currentState, int userId, int bookingId) async* {
    try {
      await MoonBlinkRepository.bookingAcceptOrDecline(userId, bookingId, BOOKING_REJECT);
      showToast('Booking Rejected');
    } catch (error) {
      showToast('$error');
      print('Error $error');
      return;
    }
  }

  bool _hasReachedMax(UserNotificationState state) =>
      state is UserNotificationSuccess && state.hasReachedMax;

  Future<List<UserNotificationData>> _fetchUserNotification(
      {int limit, int page}) async {
    UserNotificationResponse data =
        await MoonBlinkRepository.getUserNotifications(limit, page);
    return data.data;
  }
}
