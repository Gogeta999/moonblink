import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/notification_models/user_booking_notification.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:oktoast/oktoast.dart';
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
    if (event is UserBookingNotificationRefreshedFromStartPageToCurrentPage) {
      yield* _mapRefreshedFromStartPageToCurrentPage(currentState);
    }
    if (event is UserBookingNotificationChangeToRead) {
      yield* _mapChangeToReadToState(currentState, event.notificationId);
    }
    if (event is UserBookingNotificationCleared) {
      yield* _mapClearedToState(currentState);
    }
  }

  ///Initial Fetched
  Stream<UserBookingNotificationState> _mapFetchedToState(
      UserBookingNotificationState currentState) async* {
    if (currentState is UserBookingNotificationInitial) {
      List<UserBookingNotificationData> data = [];
      try {
        data = await _fetchUserNotification(limit: notificationLimit, page: 1);
      } catch (e) {
        //yield UserNotificationFailure(error: e);
        //return;
        print('$e');
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
      }
      bool hasReachedMax = data.length < notificationLimit ? true : false;
      yield data.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : UserBookingNotificationSuccess(
              data: currentState.data + data,
              hasReachedMax: hasReachedMax,
              page: nextPage);
      if (data.isEmpty) showToast('You have reached the end of the list');
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
    yield data.isEmpty
        ? UserBookingNotificationNoData()
        : UserBookingNotificationSuccess(
            data: data, hasReachedMax: hasReachedMax, page: 1);
  }

  ///Refresh from start page to current page
  Stream<UserBookingNotificationState> _mapRefreshedFromStartPageToCurrentPage(
      UserBookingNotificationState currentState) async* {
    List<UserBookingNotificationData> data = [];
    int currentPage =
        currentState is UserBookingNotificationSuccess ? currentState.page : 1;
    for (int startPage = 1; startPage <= currentPage; ++startPage) {
      try {
        data += await _fetchUserNotification(
            limit: notificationLimit, page: startPage);
      } catch (error) {
        yield UserBookingNotificationFailure(error: error);
        return;
      }
    }
    bool hasReachedMax =
        data.length < notificationLimit * currentPage ? true : false;
    yield data.isEmpty
        ? UserBookingNotificationNoData()
        : UserBookingNotificationSuccess(
            data: data, hasReachedMax: hasReachedMax, page: currentPage);
  }

  ///Notification change to read
  Stream<UserBookingNotificationState> _mapChangeToReadToState(
      UserBookingNotificationState currentState, int notificationId) async* {
    if (currentState is UserBookingNotificationSuccess) {
      List<UserBookingNotificationData> currentData = currentState.data;
      List<UserBookingNotificationData> newData = List.from(currentState.data);
      int index = 0;
      currentData.forEach((element) {
        if (element.id == notificationId) {
          index = currentData.indexOf(element);
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
        yield UserBookingNotificationSuccess(
            data: currentData,
            hasReachedMax: currentState.hasReachedMax,
            page: currentState.page);
        return;
      }
      try {
        final bookingData =
        await MoonBlinkRepository.changeUserBookingNotificationReadState(
            notificationId,
            isRead: 1);
        final data = UserBookingNotificationData(
            id: bookingData.id,
            userId: bookingData.userId,
            fcmType: bookingData.fcmType,
            title: bookingData.title,
            message: bookingData.message,
            isRead: bookingData.isRead,
            createdAt: bookingData.createdAt,
            updatedAt: bookingData.updatedAt,
            fcmData: bookingData.fcmData);
        newData[index] = data;
      } catch (error) {
        yield UserBookingNotificationFailure(error: error);
        return;
      }
      yield UserBookingNotificationSuccess(
          data: newData,
          hasReachedMax: currentState.hasReachedMax,
          page: currentState.page);
    } else {
      print('It\'s not in success state');
    }
  }

  ///ResetState
  Stream<UserBookingNotificationState> _mapClearedToState(
      UserBookingNotificationState currentState) async* {
    yield UserBookingNotificationInitial();
  }

  // ///BookingAccept
  // Stream<UserNotificationState> _mapAcceptedToState(
  //     UserNotificationState currentState,
  //     int userId,
  //     int bookingId,
  //     int bookingUserId) async* {
  //   try {
  //     await MoonBlinkRepository.bookingAcceptOrDecline(
  //         userId, bookingId, BOOKING_ACCEPT);
  //     yield UserNotificationAcceptStateToInitial();
  //     add(UserNotificationRefreshed());
  //     locator<NavigationService>()
  //         .navigateTo(RouteName.chatBox, arguments: bookingUserId);
  //     showToast('Booking Accepted');
  //   } catch (error) {
  //     showToast('$error');
  //     yield UserNotificationAcceptStateToInitial();
  //     print('Error $error');
  //     return;
  //   }
  // }
  //
  // ///BookingReject
  // Stream<UserNotificationState> _mapRejectedToState(
  //     UserNotificationState currentState, int userId, int bookingId) async* {
  //   try {
  //     await MoonBlinkRepository.bookingAcceptOrDecline(
  //         userId, bookingId, BOOKING_REJECT);
  //     yield UserNotificationRejectStateToInitial();
  //     this.add(UserNotificationRefreshed());
  //     showToast('Booking Rejected');
  //   } catch (error) {
  //     showToast('$error');
  //     yield UserNotificationRejectStateToInitial();
  //     print('Error $error');
  //     return;
  //   }
  // }

  bool _hasReachedMax(UserBookingNotificationState state) =>
      state is UserBookingNotificationSuccess && state.hasReachedMax;

  Future<List<UserBookingNotificationData>> _fetchUserNotification(
      {int limit, int page}) async {
    UserBookingNotificationResponse data =
        await MoonBlinkRepository.getUserBookingNotifications(limit, page);
    return data.data;
  }
}
