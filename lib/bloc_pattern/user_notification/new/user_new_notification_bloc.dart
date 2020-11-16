import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/notification_models/user_booking_notification.dart';
import 'package:moonblink/models/notification_models/user_new_notification.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

part 'user_new_notification_event.dart';
part 'user_new_notification_state.dart';

const int notificationLimit = 10;

class UserNewNotificationBloc
    extends Bloc<UserNewNotificationEvent, UserNewNotificationState> {
  UserNewNotificationBloc() : super(UserNewNotificationInitial());

  @override
  Stream<Transition<UserNewNotificationEvent, UserNewNotificationState>>
      transformEvents(Stream<UserNewNotificationEvent> events, transitionFn) {
    return super.transformEvents(
        events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
  }

  final markAllReadSubject = BehaviorSubject.seeded(false);

  void dispose() {
    markAllReadSubject.close();
    this.close();
  }

  @override
  Stream<UserNewNotificationState> mapEventToState(
    UserNewNotificationEvent event,
  ) async* {
    final currentState = state;
    if (event is UserNewNotificationFetched && !_hasReachedMax(currentState)) {
      yield* _mapFetchedToState(currentState);
    }
    if (event is UserNewNotificationRefreshed) {
      yield* _mapRefreshedToState(currentState);
    }
    if (event is UserNewNotificationRefreshedFromStartPageToCurrentPage) {
      yield* _mapRefreshedFromStartPageToCurrentPage(currentState);
    }
    if (event is UserNewNotificationChangeToRead) {
      yield* _mapChangeToReadToState(currentState, event.notificationId);
    }
    if (event is UserNewNotificationMarkAllRead) {
      yield* _mapMarkAllReadToState(currentState);
    }
    if (event is UserNewNotificationDelete) {
      yield* _mapDeleteToState(currentState, event.notificationId);
    }
    if (event is UserNewNotificationCleared) {
      yield* _mapClearedToState(currentState);
    }
  }

  ///Initial Fetched
  Stream<UserNewNotificationState> _mapFetchedToState(
      UserNewNotificationState currentState) async* {
    if (currentState is UserNewNotificationInitial) {
      List<UserNewNotificationData> data = [];
      int unreadCount = 0;
      try {
        var response =
            await _fetchUserNotification(limit: notificationLimit, page: 1);
        data = response.data;
        unreadCount = response.unreadCount;
      } catch (e) {
        //yield UserNotificationFailure(error: e);
        //return;
        print('$e');
      }
      bool hasReachedMax = data.length < notificationLimit ? true : false;
      yield UserNewNotificationSuccess(
          data: data,
          hasReachedMax: hasReachedMax,
          page: 1,
          unreadCount: unreadCount);
    }
    if (currentState is UserNewNotificationSuccess) {
      final nextPage = currentState.page + 1;
      List<UserNewNotificationData> data = [];
      int unreadCount = 0;
      try {
        var response = await _fetchUserNotification(
            limit: notificationLimit, page: nextPage);
        data = response.data;
        unreadCount = response.unreadCount;
      } catch (error) {
        yield UserNewNotificationFailure(error: error);
      }
      bool hasReachedMax = data.length < notificationLimit ? true : false;
      yield data.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : UserNewNotificationSuccess(
              data: currentState.data + data,
              hasReachedMax: hasReachedMax,
              page: nextPage,
              unreadCount: unreadCount);
      if (data.isEmpty) showToast('You have reached the end of the list');
    }
  }

  ///Refreshing page 1
  Stream<UserNewNotificationState> _mapRefreshedToState(
      UserNewNotificationState currentState) async* {
    List<UserNewNotificationData> data = [];
    int unreadCount = 0;
    try {
      var response =
          await _fetchUserNotification(limit: notificationLimit, page: 1);
      data = response.data;
      unreadCount = response.unreadCount;
    } catch (error) {
      yield UserNewNotificationFailure(error: error);
      return;
    }
    bool hasReachedMax = data.length < notificationLimit ? true : false;
    yield UserNewNotificationSuccess(
        data: data,
        hasReachedMax: hasReachedMax,
        page: 1,
        unreadCount: unreadCount);
  }

  ///Refresh from start page to current page
  Stream<UserNewNotificationState> _mapRefreshedFromStartPageToCurrentPage(
      UserNewNotificationState currentState) async* {
    List<UserNewNotificationData> data = [];
    int unreadCount = 0;
    int currentPage =
        currentState is UserNewNotificationSuccess ? currentState.page : 1;
    for (int startPage = 1; startPage <= currentPage; ++startPage) {
      try {
        var response = await _fetchUserNotification(
            limit: notificationLimit, page: startPage);
        data += response.data;
        unreadCount = response.unreadCount;
      } catch (error) {
        yield UserNewNotificationFailure(error: error);
        return;
      }
    }
    bool hasReachedMax =
        data.length < notificationLimit * currentPage ? true : false;
    yield UserNewNotificationSuccess(
        data: data,
        hasReachedMax: hasReachedMax,
        page: currentPage,
        unreadCount: unreadCount);
  }

  Stream<UserNewNotificationState> _mapMarkAllReadToState(
      UserNewNotificationState currentState) async* {
    if (currentState is UserNewNotificationSuccess) {
      markAllReadSubject.add(true);
      try {
        MoonBlinkRepository.markAllNotificationReadState();
        List<UserNewNotificationData> newData = List.from(currentState.data);
        newData.forEach((element) {
          element.isRead = 1;
        });
        yield currentState.copyWith(data: newData, unreadCount: 0);
        markAllReadSubject.add(false);
      } catch (e) {
        markAllReadSubject.add(false);
      }
    }
  }

  ///Notification change to read
  Stream<UserNewNotificationState> _mapChangeToReadToState(
      UserNewNotificationState currentState, int notificationId) async* {
    if (currentState is UserNewNotificationSuccess) {
      List<UserNewNotificationData> currentData = List.from(currentState.data);
      var newData;
      int index = 0;
      currentData.forEach((element) {
        if (element.id == notificationId) {
          index = currentData.indexOf(element);
          return;
        }
      });
      if (currentData[index].fcmType == 'booking') {
        /// ----- Booking -----
        final data = currentData[index].data as UserBookingNotificationData;
        if (data.fcmData.status == PENDING || data.fcmData.status == ACCEPTED) {
          locator<NavigationService>().navigateTo(RouteName.chatBox,
              arguments: data.fcmData.bookingUserId);
        } else {
          showToast("Booking Request is expired");
        }
        if (currentData[index].isRead == 1 &&
            (data.fcmData.status == REJECT ||
                data.fcmData.status == DONE ||
                data.fcmData.status == EXPIRED ||
                data.fcmData.status == UNAVAILABLE ||
                data.fcmData.status == CANCEL)) {
          return;
        }
        try {
          final bookingData =
              await MoonBlinkRepository.changeUserBookingNotificationReadState(
                  notificationId,
                  isRead: 1);
          final data = UserNewNotificationData(
              id: bookingData.id,
              userId: bookingData.userId,
              fcmType: bookingData.fcmType,
              title: bookingData.title,
              message: bookingData.message,
              isRead: bookingData.isRead,
              createdAt: bookingData.createdAt,
              updatedAt: bookingData.updatedAt,
              data: bookingData.fcmData);
          newData = data;
        } catch (error) {
          //yield UserNewNotificationFailure(error: error);
          showToast(error.toString());
          return;
        }
        currentData[index] = newData;
        yield UserNewNotificationSuccess(
            data: currentData,
            hasReachedMax: currentState.hasReachedMax,
            page: currentState.page,
            unreadCount: currentState.unreadCount == 0
                ? currentState.unreadCount
                : currentState.unreadCount - 1);
      } else if (currentData[index].fcmType == 'message') {
        /// ----- Message -----
        /// ///Already read
        if (currentData[index].isRead == 1) return;
        try {
          final messageData =
              await MoonBlinkRepository.changeUserMessageNotificationReadState(
                  notificationId,
                  isRead: 1);
          final data = UserNewNotificationData(
              id: messageData.id,
              userId: messageData.userId,
              fcmType: messageData.fcmType,
              title: messageData.title,
              message: messageData.message,
              isRead: messageData.isRead,
              createdAt: messageData.createdAt,
              updatedAt: messageData.updatedAt,
              data: messageData.messageData);
          newData = data;
        } catch (error) {
          //yield UserNewNotificationFailure(error: error);
          showToast(error.toString());
          return;
        }
        currentData[index] = newData;
        yield UserNewNotificationSuccess(
            data: currentData,
            hasReachedMax: currentState.hasReachedMax,
            page: currentState.page,
            unreadCount: currentState.unreadCount == 0
                ? currentState.unreadCount
                : currentState.unreadCount - 1);
      } else {
        print("----This type of notification is not supported for now----");
      }
    } else {
      print('It\'s not in success state');
    }
  }

  ///Notification delete
  Stream<UserNewNotificationState> _mapDeleteToState(
      UserNewNotificationState currentState, int notificationId) async* {
    if (currentState is UserNewNotificationSuccess) {
      List<UserNewNotificationData> currentData = List.from(currentState.data);
      int index = 0;
      currentData.forEach((element) {
        if (element.id == notificationId) {
          index = currentData.indexOf(element);
          return;
        }
      });
      if (currentData[index].fcmType == 'booking') {
        /// ----- Booking -----
        try {
          await MoonBlinkRepository.changeUserBookingNotificationReadState(
              notificationId,
              isArchive: 1);
          currentData.removeAt(index);
          yield UserNewNotificationDeleteSuccess();
        } catch (error) {
          yield UserNewNotificationDeleteFailure(error: error);
        }
        yield UserNewNotificationSuccess(
            data: currentData,
            hasReachedMax: currentState.hasReachedMax,
            page: currentState.page);
      } else if (currentData[index].fcmType == 'message') {
        /// ----- Message -----
        try {
          await MoonBlinkRepository.changeUserMessageNotificationReadState(
              notificationId,
              isArchive: 1);
          currentData.removeAt(index);
          yield UserNewNotificationDeleteSuccess();
        } catch (error) {
          yield UserNewNotificationDeleteFailure(error: error);
        }
        yield UserNewNotificationSuccess(
            data: currentData,
            hasReachedMax: currentState.hasReachedMax,
            page: currentState.page);
      } else {
        print("----This type of notification is not supported for now----");
      }
    } else {
      print('It\'s not in success state');
    }
  }

  ///ResetState
  Stream<UserNewNotificationState> _mapClearedToState(
      UserNewNotificationState currentState) async* {
    yield UserNewNotificationInitial();
  }

  bool _hasReachedMax(UserNewNotificationState state) =>
      state is UserNewNotificationSuccess && state.hasReachedMax;

  Future<UserNewNotificationResponse> _fetchUserNotification(
      {int limit, int page}) async {
    UserNewNotificationResponse data =
        await MoonBlinkRepository.getUserNewNotifications(limit, page);
    return data;
  }
}
