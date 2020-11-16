part of 'user_new_notification_bloc.dart';

abstract class UserNewNotificationEvent extends Equatable {
  const UserNewNotificationEvent();
}

class UserNewNotificationFetched extends UserNewNotificationEvent {
  @override
  List<Object> get props => [];
}

class UserNewNotificationCleared extends UserNewNotificationEvent {
  @override
  List<Object> get props => [];
}

class UserNewNotificationRefreshed extends UserNewNotificationEvent {
  @override
  List<Object> get props => [];
}

class UserNewNotificationRefreshedFromStartPageToCurrentPage
    extends UserNewNotificationEvent {
  @override
  List<Object> get props => [];
}

class UserNewNotificationChangeToRead extends UserNewNotificationEvent {
  final int notificationId;

  const UserNewNotificationChangeToRead(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class UserNewNotificationMarkAllRead extends UserNewNotificationEvent {
  @override
  List<Object> get props => [];
}

class UserNewNotificationDelete extends UserNewNotificationEvent {
  final int notificationId;

  const UserNewNotificationDelete(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}
