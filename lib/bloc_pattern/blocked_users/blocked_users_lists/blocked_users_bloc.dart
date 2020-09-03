import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:moonblink/models/blocked_user.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'bloc.dart';
import 'package:rxdart/rxdart.dart';

const int transactionLimit = 10;
class BlockedUsersBloc extends Bloc<BlockedUsersEvent, BlockedUsersState> {

  BlockedUsersBloc(this._listKey, this.buildRemovedItem) : super(BlockedUsersInitial());

  final GlobalKey<AnimatedListState> _listKey;
  final Widget Function(BuildContext context, int index,
      Animation<double> animation, BlockedUser data) buildRemovedItem;

  @override
  Stream<Transition<BlockedUsersEvent, BlockedUsersState>> transformEvents(
      Stream<BlockedUsersEvent> events, transitionFn) {
    return super.transformEvents(events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
  }

  @override
  Stream<BlockedUsersState> mapEventToState(
      BlockedUsersEvent event,
      ) async* {
    final currentState = state;
    if (event is BlockedUsersFetched && !_hasReachedMax(currentState)) {
      yield* _mapFetchedToState(currentState);
    }
    if (event is BlockedUsersRefreshed) {
      yield* _mapRefreshedToState(currentState);
    }
    if (event is BlockedUsersRemoved) {
      yield* _mapRemoveToState(currentState, event.index);
    }
  }

  Stream<BlockedUsersState> _mapFetchedToState(BlockedUsersState currentState) async* {
    if (currentState is BlockedUsersInitial) {
      List<BlockedUser> data = [];
      try {
        data = await _fetchUserBlockedList(
            limit: transactionLimit, page: 1);
      } catch(_) {
        yield BlockedUsersNoData();
        return;
      }
      bool hasReachedMax = data.length < transactionLimit ? true : false;
      yield BlockedUsersSuccess(data: data, hasReachedMax: hasReachedMax, page: 1);
      for (int i = 0; i <  data.length; i++) {
        await Future.delayed(Duration(milliseconds: 70));
        _listKey.currentState.insertItem(i);
      }
    }
    if (currentState is BlockedUsersSuccess) {
      final nextPage = currentState.page + 1;
      List<BlockedUser> data = [];
      try {
        data = await _fetchUserBlockedList(
            limit: transactionLimit, page: nextPage);
      } catch(error){
        yield BlockedUsersFailure(error: error);
      }
      bool hasReachedMax = data.length < transactionLimit ? true : false;
      yield data.isEmpty
          ? currentState.copyWith(hasReachedMax: true)
          : BlockedUsersSuccess(
          data: currentState.data + data, hasReachedMax: hasReachedMax, page: nextPage);
      for (int i = currentState.data.length; i < (currentState.data + data).length; i++) {
        await Future.delayed(Duration(milliseconds: 70));
        _listKey.currentState.insertItem(i);
      }
    }
  }

  Stream<BlockedUsersState> _mapRefreshedToState(BlockedUsersState currentState) async* {
    List<BlockedUser> data = [];
    if (currentState is BlockedUsersSuccess) {
      for (int i = currentState.data.length - 1; i >= 0; --i) {
        print(i);
        _listKey.currentState.removeItem(i, (context, animation) {
          return buildRemovedItem(context, i, animation, currentState.data[i]);
          }, duration: Duration(milliseconds: 10));
      }
      //currentState.data.clear();
    }
    try {
      data = await _fetchUserBlockedList(
          limit: transactionLimit, page: 1);
    } catch (error) {
      yield BlockedUsersFailure(error: error);
    }
    bool hasReachedMax = data.length < transactionLimit ? true : false;
    yield data.isEmpty
        ? BlockedUsersNoData()
        : BlockedUsersSuccess(
          data: data, hasReachedMax: hasReachedMax, page: 1);
      for (int i = 0; i <  data.length; i++) {
        await Future.delayed(Duration(milliseconds: 70));
        _listKey.currentState.insertItem(i);
      }
  }

  Stream<BlockedUsersState> _mapRemoveToState(BlockedUsersState currentState, int index) async* {
    if (currentState is BlockedUsersSuccess) {
      List<BlockedUser> data = List()..addAll(currentState.data);
      data.removeAt(index);
      _listKey.currentState.removeItem(index, (context, animation) {
        return buildRemovedItem(context, index, animation, currentState.data[index]);
      });
      yield currentState.copyWith(data: data);
      return;
    }
  }

  bool _hasReachedMax(BlockedUsersState state) =>
      state is BlockedUsersSuccess && state.hasReachedMax;

  Future<List<BlockedUser>> _fetchUserBlockedList({int limit, int page}) async {
    BlockedUsersList blockedUsersList = await MoonBlinkRepository.getUserBlockedList(
        limit: limit, page: page);
    return blockedUsersList.blockedUsersList;
  }
}