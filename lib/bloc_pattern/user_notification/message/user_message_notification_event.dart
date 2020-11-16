part of 'user_message_notification_bloc.dart';

abstract class UserMessageNotificationEvent extends Equatable {
  const UserMessageNotificationEvent();

  @override
  List<Object> get props => [];
}

class UserMessageNotificationFetched extends UserMessageNotificationEvent {}

class UserMessageNotificationCleared extends UserMessageNotificationEvent {}

class UserMessageNotificationRefreshed extends UserMessageNotificationEvent {}
