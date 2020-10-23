part of 'user_message_notification_bloc.dart';

abstract class UserMessageNotificationState extends Equatable {
  const UserMessageNotificationState();

  @override
  List<Object> get props => [];
}

class UserMessageNotificationInitial extends UserMessageNotificationState {
  @override
  List<Object> get props => [];
}

class UserMessageNotificationFailure extends UserMessageNotificationState {
  final error;

  const UserMessageNotificationFailure({this.error});

  @override
  List<Object> get props => [error];

}

class UserMessageNotificationNoData extends UserMessageNotificationState {
  @override
  List<Object> get props => [];

}

class UserMessageNotificationSuccess extends UserMessageNotificationState {
  final List<UserMessageNotificationData> data;
  final bool hasReachedMax;
  final int page;

  const UserMessageNotificationSuccess({this.data, this.hasReachedMax, this.page});

  UserMessageNotificationSuccess copyWith({List<UserMessageNotificationData> data, bool hasReachedMax, int page}) {
    return UserMessageNotificationSuccess(
        data: data ?? this.data,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        page: page ?? this.page
    );
  }

  @override
  List<Object> get props => [data, hasReachedMax, page];

  @override
  String toString() => 'UserNewNotificationSuccess: ${data.length}, hasReachedMax: $hasReachedMax';
}