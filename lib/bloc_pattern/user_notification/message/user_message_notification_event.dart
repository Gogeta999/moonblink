part of 'user_message_notification_bloc.dart';

abstract class UserMessageNotificationEvent extends Equatable {
  const UserMessageNotificationEvent();

  @override
  List<Object> get props => [];
}

class UserMessageNotificationFetched extends UserMessageNotificationEvent {}

class UserMessageNotificationCleared extends UserMessageNotificationEvent {}

class UserMessageNotificationRefreshed extends UserMessageNotificationEvent {}

class UserMessageNotificationRefreshedFromStartPageToCurrentPage
    extends UserMessageNotificationEvent {}

class UserMessageNotificationChangeToRead extends UserMessageNotificationEvent {
  final int notificationId;

  const UserMessageNotificationChangeToRead(this.notificationId);
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