part of 'user_notification_bloc.dart';

abstract class UserNotificationEvent extends Equatable {
  const UserNotificationEvent();

  @override
  List<Object> get props => [];
}

class UserNotificationFetched extends UserNotificationEvent {}

class UserNotificationRefreshed extends UserNotificationEvent {}

class UserNotificationAccepted extends UserNotificationEvent {
  final int userId;
  final int bookingUserId;

  const UserNotificationAccepted(this.userId, this.bookingUserId);
}

class UserNotificationRejected extends UserNotificationEvent {
  final int userId;
  final int bookingUserId;

  const UserNotificationRejected(this.userId, this.bookingUserId);
}