import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:moonblink/models/transaction.dart';
import 'package:moonblink/models/user_transaction.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'bloc.dart';
import 'package:rxdart/rxdart.dart';

const int transactionLimit = 15;
class UserTransactionBloc extends Bloc<UserTransactionEvent, UserTransactionState> {

  UserTransactionBloc() : super(UserTransactionInitial());

  @override
  Stream<Transition<UserTransactionEvent, UserTransactionState>> transformEvents(
      Stream<UserTransactionEvent> events, transitionFn) {
    return super.transformEvents(events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
  }

  @override
  Stream<UserTransactionState> mapEventToState(
      UserTransactionEvent event,
      ) async* {
    final currentState = state;
    if (event is UserTransactionFetched && !_hasReachedMax(currentState)) {
      if (currentState is UserTransactionInitial) {
        List<Transaction> data = [];
        try {
          data = await _fetchUserTransaction(
              limit: transactionLimit, page: 1);
        } catch(_) {
          yield UserTransactionNoData();
        }
        bool hasReachedMax = data.length < transactionLimit ? true : false;
        yield UserTransactionSuccess(data: data, hasReachedMax: hasReachedMax, page: 1);
      }
      if (currentState is UserTransactionSuccess) {
        final nextPage = currentState.page + 1;
        List<Transaction> data = [];
        try {
          data = await _fetchUserTransaction(
              limit: transactionLimit, page: nextPage);
        } catch(error){
          yield UserTransactionFailure(error: error);
        }
        bool hasReachedMax = data.length < transactionLimit ? true : false;
        yield data.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : UserTransactionSuccess(
            data: currentState.data + data, hasReachedMax: hasReachedMax, page: nextPage);
      }
    }

    if (event is UserTransactionRefreshed) {
      yield* _mapRefreshedToState(currentState);
    }
  }

  Stream<UserTransactionState> _mapRefreshedToState(UserTransactionState currentState) async* {
    List<Transaction> data = [];
    if (currentState is UserTransactionSuccess) currentState.data.clear();
    try {
      data = await _fetchUserTransaction(
          limit: transactionLimit, page: 1);
    } catch (error) {
      yield UserTransactionFailure(error: error);
    }
    bool hasReachedMax = data.length < transactionLimit ? true : false;
    yield data.isEmpty
        ? UserTransactionNoData()
        : UserTransactionSuccess(data: data, hasReachedMax: hasReachedMax, page: 1);
  }

  bool _hasReachedMax(UserTransactionState state) =>
      state is UserTransactionSuccess && state.hasReachedMax;

  Future<List<Transaction>> _fetchUserTransaction({int limit, int page}) async {
    UserTransaction userTransaction = await MoonBlinkRepository.getUserTransaction(
        limit: limit, page: page);
    return userTransaction.data;
  }
}
