part of 'user_rating_bloc.dart';

abstract class UserRatingEvent extends Equatable {
  const UserRatingEvent();
}

class UserRatingFetched extends UserRatingEvent {
  @override
  List<Object> get props => [];
}

class UserRatingRefreshed extends UserRatingEvent {
  @override
  List<Object> get props => [];
}