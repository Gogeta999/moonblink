import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moonblink/base_widget/booking/booking_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/user_notification.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:moonblink/utils/constants.dart';
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
    if (event is UserNotificationRefreshedFromStartPageToCurrentPage) {
      yield* _mapRefreshedFromStartPageToCurrentPage(currentState);
    }
    if (event is UserNotificationChangeToRead) {
      yield* _mapChangeToReadToState(currentState, event.notificationId);
    }
    if (event is UserNotificationCleared) {
      yield* _mapClearedToState(currentState);
    }
    if (event is UserNotificationAccepted) {
      yield* _mapAcceptedToState(
          currentState, event.userId, event.bookingId, event.bookingUserId);
    }
    if (event is UserNotificationRejected) {
      yield* _mapRejectedToState(currentState, event.userId, event.bookingId);
    }
  }

  ///Initial Fetched
  Stream<UserNotificationState> _mapFetchedToState(
      UserNotificationState currentState) async* {
    if (currentState is UserNotificationInitial) {
      List<UserNotificationData> data = [];
      try {
        data = await _fetchUserNotification(limit: notificationLimit, page: 1);
      } catch (e) {
        //yield UserNotificationFailure(error: e);
        //return;
        print('$e');
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
      if (data.isEmpty) showToast('You have reached the end of the list');
    }
  }

  ///Refreshing page 1
  Stream<UserNotificationState> _mapRefreshedToState(
      UserNotificationState currentState) async* {
    List<UserNotificationData> data = [];
    try {
      data = await _fetchUserNotification(limit: notificationLimit, page: 1);
    } catch (error) {
      yield UserNotificationAcceptStateToInitial();
      yield UserNotificationRejectStateToInitial();
      yield UserNotificationFailure(error: error);
      return;
    }
    bool hasReachedMax = data.length < notificationLimit ? true : false;
    yield data.isEmpty
        ? UserNotificationNoData()
        : UserNotificationSuccess(
            data: data, hasReachedMax: hasReachedMax, page: 1);
  }

  ///Refresh from start page to current page
  Stream<UserNotificationState> _mapRefreshedFromStartPageToCurrentPage(
      UserNotificationState currentState) async* {
    List<UserNotificationData> data = [];
    int currentPage =
        currentState is UserNotificationSuccess ? currentState.page : 1;
    for (int startPage = 1; startPage <= currentPage; ++startPage) {
      try {
        data += await _fetchUserNotification(
            limit: notificationLimit, page: startPage);
      } catch (error) {
        yield UserNotificationFailure(error: error);
        return;
      }
    }
    bool hasReachedMax =
        data.length < notificationLimit * currentPage ? true : false;
    yield data.isEmpty
        ? UserNotificationNoData()
        : UserNotificationSuccess(
            data: data, hasReachedMax: hasReachedMax, page: currentPage);
  }

  ///Notification change to read
  Stream<UserNotificationState> _mapChangeToReadToState(
      UserNotificationState currentState, int notificationId) async* {
    if (currentState is UserNotificationSuccess) {
      List<UserNotificationData> currentData = currentState.data;
      UserNotificationData data;
      int index = 0;
      currentData.forEach((element) {
        if (element.id == notificationId) {
          index = currentData.indexOf(element);
//          print('------------------------Returning from loop');
          return;
        }
      });
      if (currentData[index].fcmData.status == PENDING) {
        await locator<NavigationService>().navigateTo(RouteName.chatBox,
            arguments: currentData[index].fcmData.bookingUserId);
      } else {
        showToast("Booking Request is expired");
      }

      if (currentData[index].isRead == 1 &&
          (currentData[index].fcmData.status == REJECT ||
              currentData[index].fcmData.status == DONE ||
              currentData[index].fcmData.status == EXPIRED ||
              currentData[index].fcmData.status == UNAVAILABLE ||
              currentData[index].fcmData.status == CANCEL)) {
        ///old booking notification and already read
        yield currentState.copyWith();
        return;
      }
      // yield UserNotificationUpdating(
      //     data: currentState.data,
      //     hasReachedMax: currentState.hasReachedMax,
      //     page: currentState.page);
      try {
        data = await MoonBlinkRepository.changeUserNotificationReadState(
            notificationId);
      } catch (error) {
        yield UserNotificationFailure(error: error);
        return;
      }
      currentData[index] = data;
      yield currentState.copyWith(data: currentData);
    } else {
      print('It\'s not in success state');
    }
  }

  ///ResetState
  Stream<UserNotificationState> _mapClearedToState(
      UserNotificationState currentState) async* {
    yield UserNotificationInitial();
  }

  ///BookingAccept
  Stream<UserNotificationState> _mapAcceptedToState(
      UserNotificationState currentState,
      int userId,
      int bookingId,
      int bookingUserId) async* {
    try {
      await MoonBlinkRepository.bookingAcceptOrDecline(
          userId, bookingId, BOOKING_ACCEPT);
      yield UserNotificationAcceptStateToInitial();
      add(UserNotificationRefreshed());
      locator<NavigationService>()
          .navigateTo(RouteName.chatBox, arguments: bookingUserId);
      showToast('Booking Accepted');
    } catch (error) {
      showToast('$error');
      yield UserNotificationAcceptStateToInitial();
      print('Error $error');
      return;
    }
  }

  ///BookingReject
  Stream<UserNotificationState> _mapRejectedToState(
      UserNotificationState currentState, int userId, int bookingId) async* {
    try {
      await MoonBlinkRepository.bookingAcceptOrDecline(
          userId, bookingId, BOOKING_REJECT);
      yield UserNotificationRejectStateToInitial();
      this.add(UserNotificationRefreshed());
      showToast('Booking Rejected');
    } catch (error) {
      showToast('$error');
      yield UserNotificationRejectStateToInitial();
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
