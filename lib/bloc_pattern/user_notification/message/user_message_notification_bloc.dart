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
    if (event is UserMessageNotificationRefreshedFromStartPageToCurrentPage) {
      yield* _mapRefreshedFromStartPageToCurrentPage(currentState);
    }
    if (event is UserMessageNotificationChangeToRead) {
      yield* _mapChangeToReadToState(currentState, event.notificationId);
    }
    if (event is UserMessageNotificationCleared) {
      yield* _mapClearedToState(currentState);
    }
    // if (event is UserNotificationAccepted) {
    //   yield* _mapAcceptedToState(
    //       currentState, event.userId, event.bookingId, event.bookingUserId);
    // }
    // if (event is UserNotificationRejected) {
    //   yield* _mapRejectedToState(currentState, event.userId, event.bookingId);
    // }
  }

  ///Initial Fetched
  Stream<UserMessageNotificationState> _mapFetchedToState(
      UserMessageNotificationState currentState) async* {
    if (currentState is UserMessageNotificationInitial) {
      List<UserMessageNotificationData> data = [];
      try {
        data = await _fetchUserNotification(limit: notificationLimit, page: 1);
      } catch (e) {
        //yield UserNotificationFailure(error: e);
        //return;
        print('$e');
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
        yield UserMessageNotificationFailure(error: error);
      }
      bool hasReachedMax = data.length < notificationLimit ? true : false;
      yield data.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : UserMessageNotificationSuccess(
              data: currentState.data + data,
              hasReachedMax: hasReachedMax,
              page: nextPage);
      if (data.isEmpty) showToast('You have reached the end of the list');
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
    yield data.isEmpty
        ? UserMessageNotificationNoData()
        : UserMessageNotificationSuccess(
            data: data, hasReachedMax: hasReachedMax, page: 1);
  }

  ///Refresh from start page to current page
  Stream<UserMessageNotificationState> _mapRefreshedFromStartPageToCurrentPage(
      UserMessageNotificationState currentState) async* {
    List<UserMessageNotificationData> data = [];
    int currentPage =
        currentState is UserMessageNotificationSuccess ? currentState.page : 1;
    for (int startPage = 1; startPage <= currentPage; ++startPage) {
      try {
        data += await _fetchUserNotification(
            limit: notificationLimit, page: startPage);
      } catch (error) {
        yield UserMessageNotificationFailure(error: error);
        return;
      }
    }
    bool hasReachedMax =
        data.length < notificationLimit * currentPage ? true : false;
    yield data.isEmpty
        ? UserMessageNotificationNoData()
        : UserMessageNotificationSuccess(
            data: data, hasReachedMax: hasReachedMax, page: currentPage);
  }

  ///Notification change to read
  Stream<UserMessageNotificationState> _mapChangeToReadToState(
      UserMessageNotificationState currentState, int notificationId) async* {
    if (currentState is UserMessageNotificationSuccess) {
      List<UserMessageNotificationData> currentData = currentState.data;
      UserMessageNotificationData data;
      int index = 0;
      currentData.forEach((element) {
        if (element.id == notificationId) {
          index = currentData.indexOf(element);
//          print('------------------------Returning from loop');
          return;
        }
      });
      yield UserMessageNotificationUpdating(
          data: currentData,
          hasReachedMax: currentState.hasReachedMax,
          page: currentState.page);
      try {
        data = await MoonBlinkRepository.changeUserMessageNotificationReadState(
            notificationId,
            isRead: 1);
      } catch (error) {
        yield UserMessageNotificationFailure(error: error);
        return;
      }
      currentData[index] = data;
      yield UserMessageNotificationSuccess(
          data: currentData,
          hasReachedMax: currentState.hasReachedMax,
          page: currentState.page);
    } else {
      print('It\'s not in success state');
    }
  }

  ///ResetState
  Stream<UserMessageNotificationState> _mapClearedToState(
      UserMessageNotificationState currentState) async* {
    yield UserMessageNotificationInitial();
  }

  // ///MessageAccept
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
  //     showToast('Message Accepted');
  //   } catch (error) {
  //     showToast('$error');
  //     yield UserNotificationAcceptStateToInitial();
  //     print('Error $error');
  //     return;
  //   }
  // }
  //
  // ///MessageReject
  // Stream<UserNotificationState> _mapRejectedToState(
  //     UserNotificationState currentState, int userId, int bookingId) async* {
  //   try {
  //     await MoonBlinkRepository.bookingAcceptOrDecline(
  //         userId, bookingId, BOOKING_REJECT);
  //     yield UserNotificationRejectStateToInitial();
  //     this.add(UserNotificationRefreshed());
  //     showToast('Message Rejected');
  //   } catch (error) {
  //     showToast('$error');
  //     yield UserNotificationRejectStateToInitial();
  //     print('Error $error');
  //     return;
  //   }
  // }

  bool _hasReachedMax(UserMessageNotificationState state) =>
      state is UserMessageNotificationSuccess && state.hasReachedMax;

  Future<List<UserMessageNotificationData>> _fetchUserNotification(
      {int limit, int page}) async {
    UserMessageNotificationResponse data =
        await MoonBlinkRepository.getUserMessageNotifications(limit, page);
    return data.data;
  }
}
