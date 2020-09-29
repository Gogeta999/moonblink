part of 'user_booking_notification_bloc.dart';

abstract class UserBookingNotificationEvent extends Equatable {
  const UserBookingNotificationEvent();

  @override
  List<Object> get props => [];
}

class UserBookingNotificationFetched extends UserBookingNotificationEvent {}

class UserBookingNotificationCleared extends UserBookingNotificationEvent {}

class UserBookingNotificationRefreshed extends UserBookingNotificationEvent {}

class UserBookingNotificationRefreshedFromStartPageToCurrentPage
    extends UserBookingNotificationEvent {}

class UserBookingNotificationChangeToRead extends UserBookingNotificationEvent {
  final int notificationId;

  const UserBookingNotificationChangeToRead(this.notificationId);
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