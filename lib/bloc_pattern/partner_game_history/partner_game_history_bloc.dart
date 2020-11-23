import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:moonblink/models/transaction.dart';
import 'package:moonblink/models/user_history.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'bloc.dart';
import 'package:rxdart/rxdart.dart';

const int historyLimit = 5;

class PartnerGameHistoryBloc
    extends Bloc<PartnerGameHistoryEvent, PartnerGameHistoryState> {
  final int partnerId;

  PartnerGameHistoryBloc({this.partnerId}) : super(PartnerGameHistoryInitial());

  @override
  Stream<Transition<PartnerGameHistoryEvent, PartnerGameHistoryState>>
      transformEvents(Stream<PartnerGameHistoryEvent> events, transitionFn) {
    return super.transformEvents(
        events.debounceTime(const Duration(milliseconds: 500)), transitionFn);
  }

  void dispose() {
    this.close();
  }

  @override
  Stream<PartnerGameHistoryState> mapEventToState(
    PartnerGameHistoryEvent event,
  ) async* {
    final currentState = state;
    if (event is PartnerGameHistoryFetched && !_hasReachedMax(currentState)) {
      if (currentState is PartnerGameHistoryInitial) {
        List<Transaction> data = [];
        try {
          data = await _fetchPartnerGameHistory(
              partnerId: partnerId, limit: historyLimit, page: 1);
        } catch (_) {
          yield PartnerGameHistoryNoData();
        }
        bool hasReachedMax = data.length < historyLimit ? true : false;
        yield PartnerGameHistorySuccess(
            data: data, hasReachedMax: hasReachedMax, page: 1);
        return;
      }
      if (currentState is PartnerGameHistorySuccess) {
        final nextPage = currentState.page + 1;
        List<Transaction> data = [];
        try {
          data = await _fetchPartnerGameHistory(
              partnerId: partnerId, limit: historyLimit, page: nextPage);
        } catch (error) {
          yield PartnerGameHistoryFailure(error: error);
        }
        bool hasReachedMax = data.length < historyLimit ? true : false;
        yield data.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : PartnerGameHistorySuccess(
                data: currentState.data + data,
                hasReachedMax: hasReachedMax,
                page: nextPage);
        return;
      }
    }

    /*if (event is PartnerGameHistoryRefreshed) {
      try {
        if (currentState is PartnerGameHistoryInitial) {
          final data = await _fetchPartnerGameHistory(partnerId: partnerId, limit: historyLimit, page: 1);
          bool hasReachedMax = data.length < 5 ? true : false;
          yield PartnerGameHistorySuccess(data: data, hasReachedMax: hasReachedMax, page: 1);
          return;
        }
        if (currentState is PartnerGameHistorySuccess) {
          final data = await _fetchPartnerGameHistory(
              partnerId: partnerId, limit: 1, page: 1);
          bool hasReachedMax = data.length < 5 ? true : false;
          yield data.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : PartnerGameHistorySuccess(
              data: currentState.data + data,
              hasReachedMax: hasReachedMax,
              page: 1);
          return;
        }
      } catch (_) {
        yield PartnerGameHistoryFailure();
      }
    }*/
  }

  bool _hasReachedMax(PartnerGameHistoryState state) =>
      state is PartnerGameHistorySuccess && state.hasReachedMax;

  Future<List<Transaction>> _fetchPartnerGameHistory(
      {int partnerId, int limit, int page}) async {
    UserHistory userHistory = await MoonBlinkRepository.getUserHistory(
        partnerId: partnerId, limit: limit, page: page);
    return userHistory.data;
  }
}
