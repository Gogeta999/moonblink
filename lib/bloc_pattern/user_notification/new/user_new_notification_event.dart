part of 'user_new_notification_bloc.dart';

abstract class UserNewNotificationEvent extends Equatable {
  const UserNewNotificationEvent();

  @override
  List<Object> get props => [];
}

class UserNewNotificationFetched extends UserNewNotificationEvent {}

class UserNewNotificationCleared extends UserNewNotificationEvent {}

class UserNewNotificationRefreshed extends UserNewNotificationEvent {}

class UserNewNotificationRefreshedFromStartPageToCurrentPage
    extends UserNewNotificationEvent {}

class UserNewNotificationChangeToRead extends UserNewNotificationEvent {
  final int notificationId;

  const UserNewNotificationChangeToRead(this.notificationId);
}

class UserNewNotificationDelete extends UserNewNotificationEvent {
  final int notificationId;

  const UserNewNotificationDelete(this.notificationId);
}

// class UserNotificationAccepted extends UserNotificationEvent {
//   final int userId;
//   final int bookingId;
//   final int bookingUserId;
//
//   const UserNotificationAccepted(this.userId, this.bookingId, this.bookingUserId);
// }
//
// class UserNotificationRejected extends UserNotificationEvent {
//   final int userId;
//   final int bookingId;
//
//   const UserNotificationRejected(this.userId, this.bookingId);
// }