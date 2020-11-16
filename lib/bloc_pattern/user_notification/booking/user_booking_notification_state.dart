part of 'user_booking_notification_bloc.dart';

abstract class UserBookingNotificationState extends Equatable {
  const UserBookingNotificationState();

  @override
  List<Object> get props => [];
}

class UserBookingNotificationInitial extends UserBookingNotificationState {
  @override
  List<Object> get props => [];
}

class UserBookingNotificationFailure extends UserBookingNotificationState {
  final error;

  const UserBookingNotificationFailure({this.error});

  @override
  List<Object> get props => [error];
}

class UserBookingNotificationSuccess extends UserBookingNotificationState {
  final List<UserBookingNotificationData> data;
  final bool hasReachedMax;
  final int page;

  const UserBookingNotificationSuccess(
      {this.data, this.hasReachedMax, this.page});

  UserBookingNotificationSuccess copyWith(
      {List<UserBookingNotificationData> data, bool hasReachedMax, int page}) {
    return UserBookingNotificationSuccess(
        data: data ?? this.data,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        page: page ?? this.page);
  }

  @override
  List<Object> get props => [data, hasReachedMax, page];

  @override
  String toString() =>
      'UserTransactionSuccess: ${data.length}, hasReachedMax: $hasReachedMax';
}
