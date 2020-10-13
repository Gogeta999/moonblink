part of 'user_rating_bloc.dart';

abstract class UserRatingState extends Equatable {
  const UserRatingState();
}

class UserRatingInitial extends UserRatingState {
  @override
  List<Object> get props => [];
}

class UserRatingFailure extends UserRatingState {
  final error;

  const UserRatingFailure({this.error});

  @override
  List<Object> get props => [error];

}

class UserRatingNoData extends UserRatingState {
  @override
  List<Object> get props => [];

}

class UserRatingRefreshing extends UserRatingState {
  @override
  List<Object> get props => [];

}

class UserRatingSuccess extends UserRatingState {
  final List<UserRating> data;
  final bool hasReachedMax;
  final int page;

  const UserRatingSuccess({this.data, this.hasReachedMax, this.page});

  UserRatingSuccess copyWith({List<UserRating> data, bool hasReachedMax, int page}) {
    return UserRatingSuccess(
        data: data ?? this.data,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        page: page ?? this.page
    );
  }

  @override
  List<Object> get props => [data, hasReachedMax];

  @override
  String toString() => 'UserRatingSuccess: ${data.length}, hasReachedMax: $hasReachedMax';
}