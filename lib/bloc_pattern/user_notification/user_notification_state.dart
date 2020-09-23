part of 'user_notification_bloc.dart';

abstract class UserNotificationState extends Equatable {
  const UserNotificationState();
}

class UserNotificationInitial extends UserNotificationState {
  @override
  List<Object> get props => [];
}

class UserNotificationFailure extends UserNotificationState {
  final error;

  const UserNotificationFailure({this.error});

  @override
  List<Object> get props => [error];

}

class UserNotificationNoData extends UserNotificationState {
  @override
  List<Object> get props => [];

}

class UserNotificationSuccess extends UserNotificationState {
  final List<UserNotificationData> data;
  final bool hasReachedMax;
  final int page;

  const UserNotificationSuccess({this.data, this.hasReachedMax, this.page});

  UserNotificationSuccess copyWith({List<UserNotificationData> data, bool hasReachedMax, int page}) {
    return UserNotificationSuccess(
        data: data ?? this.data,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        page: page ?? this.page
    );
  }

  @override
  List<Object> get props => [data, hasReachedMax];

  @override
  String toString() => 'UserTransactionSuccess: ${data.length}, hasReachedMax: $hasReachedMax';
}