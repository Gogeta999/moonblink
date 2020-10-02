part of 'user_new_notification_bloc.dart';

abstract class UserNewNotificationState extends Equatable {
  const UserNewNotificationState();

  @override
  List<Object> get props => [];
}

class UserNewNotificationInitial extends UserNewNotificationState {
  @override
  List<Object> get props => [];
}

class UserNewNotificationFailure extends UserNewNotificationState {
  final error;

  const UserNewNotificationFailure({this.error});

  @override
  List<Object> get props => [error];

}

class UserNewNotificationUpdating extends UserNewNotificationState {
  final List<UserNewNotificationData> data;
  final int unreadCount;
  final bool hasReachedMax;
  final int page;

  const UserNewNotificationUpdating({this.data, this.hasReachedMax, this.page, this.unreadCount});

  @override
  List<Object> get props => [data, hasReachedMax];

  @override
  String toString() => 'UserTransactionSuccess: ${data.length}, hasReachedMax: $hasReachedMax';
}

class UserNewNotificationNoData extends UserNewNotificationState {
  @override
  List<Object> get props => [];

}

class UserNewNotificationSuccess extends UserNewNotificationState {
  final List<UserNewNotificationData> data;
  final int unreadCount;
  final bool hasReachedMax;
  final int page;

  const UserNewNotificationSuccess({this.data, this.hasReachedMax, this.page, this.unreadCount});

  UserNewNotificationSuccess copyWith({List<UserNewNotificationData> data, bool hasReachedMax, int page, int unreadCount}) {
    return UserNewNotificationSuccess(
        data: data ?? this.data,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        page: page ?? this.page,
        unreadCount: unreadCount ?? this.unreadCount
    );
  }

  @override
  List<Object> get props => [data, hasReachedMax];

  @override
  String toString() => 'UserTransactionSuccess: ${data.length}, hasReachedMax: $hasReachedMax';
}

class UserNewNotificationDeleteSuccess extends UserNewNotificationState {}

class UserNewNotificationDeleteFailure extends UserNewNotificationState {
  final error;

  const UserNewNotificationDeleteFailure({this.error});
}

// class UserNotificationAcceptStateToInitial extends UserNotificationState {}
//
// class UserNotificationRejectStateToInitial extends UserNotificationState {}