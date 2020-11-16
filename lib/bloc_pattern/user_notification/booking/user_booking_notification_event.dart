part of 'user_booking_notification_bloc.dart';

abstract class UserBookingNotificationEvent extends Equatable {
  const UserBookingNotificationEvent();

  @override
  List<Object> get props => [];
}

class UserBookingNotificationFetched extends UserBookingNotificationEvent {}

class UserBookingNotificationCleared extends UserBookingNotificationEvent {}

class UserBookingNotificationRefreshed extends UserBookingNotificationEvent {}
