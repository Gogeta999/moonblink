part of 'user_notification_bloc.dart';

abstract class UserNotificationEvent extends Equatable {
  const UserNotificationEvent();

  @override
  List<Object> get props => [];
}

class UserNotificationFetched extends UserNotificationEvent {}

class UserNotificationCleared extends UserNotificationEvent {}

class UserNotificationRefreshed extends UserNotificationEvent {}

class UserNotificationRefreshedFromStartPageToCurrentPage
    extends UserNotificationEvent {}

class UserNotificationChangeToRead extends UserNotificationEvent {
  final int notificationId;

  const UserNotificationChangeToRead(this.notificationId);
}

class UserNotificationAccepted extends UserNotificationEvent {
  final int userId;
  final int bookingId;
  final int bookingUserId;

  const UserNotificationAccepted(this.userId, this.bookingId, this.bookingUserId);
}

class UserNotificationRejected extends UserNotificationEvent {
  final int userId;
  final int bookingId;

  const UserNotificationRejected(this.userId, this.bookingId);
}