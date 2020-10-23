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
      List<UserMessageNotificationData> newData = List.from(currentState.data);
      int index = 0;
      currentData.forEach((element) {
        if (element.id == notificationId) {
          index = currentData.indexOf(element);
          return;
        }
      });
      ///Already read
      if (currentData[index].isRead == 1) return;
      try {
        final messageData =
        await MoonBlinkRepository.changeUserMessageNotificationReadState(
            notificationId,
            isRead: 1);
        final data = UserMessageNotificationData(
            id: messageData.id,
            userId: messageData.userId,
            fcmType: messageData.fcmType,
            title: messageData.title,
            message: messageData.message,
            isRead: messageData.isRead,
            createdAt: messageData.createdAt,
            updatedAt: messageData.updatedAt,
            messageData: messageData.messageData);
        newData[index] = data;
      } catch (error) {
        yield UserMessageNotificationFailure(error: error);
        return;
      }
      yield UserMessageNotificationSuccess(
          data: newData,
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

  bool _hasReachedMax(UserMessageNotificationState state) =>
      state is UserMessageNotificationSuccess && state.hasReachedMax;

  Future<List<UserMessageNotificationData>> _fetchUserNotification(
      {int limit, int page}) async {
    UserMessageNotificationResponse data =
        await MoonBlinkRepository.getUserMessageNotifications(limit, page);
    return data.data;
  }
}
