import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moonblink/models/user_rating.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'user_rating_event.dart';
part 'user_rating_state.dart';

const int ratingLimit = 5;

class UserRatingBloc extends Bloc<UserRatingEvent, UserRatingState> {
  final int userId;

  UserRatingBloc(this.userId) : super(UserRatingInitial());

  @override
  Stream<Transition<UserRatingEvent, UserRatingState>> transformEvents(
      Stream<UserRatingEvent> events, transitionFn) {
    return super.transformEvents(
        events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
  }

  void dispose() {
    this.close();
  }

  @override
  Stream<UserRatingState> mapEventToState(
    UserRatingEvent event,
  ) async* {
    final currentState = state;
    if (event is UserRatingFetched && !_hasReachedMax(currentState)) {
      yield* _mapFetchedToState(currentState);
    }
    if (event is UserRatingRefreshed) {
      yield* _mapRefreshedToState(currentState);
    }
  }

  Stream<UserRatingState> _mapFetchedToState(
      UserRatingState currentState) async* {
    if (currentState is UserRatingInitial) {
      List<UserRating> data = [];
      try {
        data = await _fetchUserRating(limit: ratingLimit, page: 1);
      } catch (e) {
        yield UserRatingFailure(error: e);
        return;
      }
      bool hasReachedMax = data.length < ratingLimit ? true : false;
      yield UserRatingSuccess(
          data: data, hasReachedMax: hasReachedMax, page: 1);
    }
    if (currentState is UserRatingSuccess) {
      final nextPage = currentState.page + 1;
      List<UserRating> data = [];
      try {
        data = await _fetchUserRating(limit: ratingLimit, page: nextPage);
      } catch (error) {
        yield UserRatingFailure(error: error);
      }
      bool hasReachedMax = data.length < ratingLimit ? true : false;
      yield data.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : UserRatingSuccess(
              data: currentState.data + data,
              hasReachedMax: hasReachedMax,
              page: nextPage);
    }
  }

  Stream<UserRatingState> _mapRefreshedToState(
      UserRatingState currentState) async* {
    List<UserRating> data = [];
    yield UserRatingRefreshing();
    try {
      data = await _fetchUserRating(limit: ratingLimit, page: 1);
    } catch (error) {
      yield UserRatingFailure(error: error);
      return;
    }
    bool hasReachedMax = data.length < ratingLimit ? true : false;
    yield data.isEmpty
        ? UserRatingNoData()
        : UserRatingSuccess(data: data, hasReachedMax: hasReachedMax, page: 1);
  }

  bool _hasReachedMax(UserRatingState state) =>
      state is UserRatingSuccess && state.hasReachedMax;

  Future<List<UserRating>> _fetchUserRating({int limit, int page}) async {
    UserRatingList data =
        await MoonBlinkRepository.userRating(userId, limit, page);
    return data.userRatingList;
  }
}
