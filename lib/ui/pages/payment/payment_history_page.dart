import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/payments/payment.dart';
import 'package:moonblink/provider/view_state.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class PaymentHistoryPage extends StatefulWidget {
  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final ScrollController _scrollController = ScrollController();
  Completer<void> _refreshCompleter = Completer<void>();
  double _scrollThreshold = 800.0;
  Timer _debounce;

  final _paymentsSubject = BehaviorSubject<List<Payment>>.seeded(null);

  final _limit = 20;
  int _nextPage = 1;
  bool _hasReachedMax = false;
  bool _isFetching = false;

  @override
  void initState() {
    _scrollController.addListener(() => _onScroll());
    _fetchInitialData();
    super.initState();
  }

  void dispose() {
    _debounce?.cancel();
    _paymentsSubject.close();
    super.dispose();
  }

  void _refreshData() {
    _nextPage = 1;
    _isFetching = false;
    MoonBlinkRepository.getUserPayments(_limit, _nextPage).then((value) {
      _paymentsSubject.add(null);
      _refreshCompleter?.complete();
      _refreshCompleter = Completer<void>();
      _hasReachedMax = value.length < _limit;
      _nextPage++;
      Future.delayed(Duration(milliseconds: 50), () {
        _paymentsSubject.add(value);
      });
    }, onError: (e) {
      _paymentsSubject.addError(e);
      _refreshCompleter?.completeError(e);
      _refreshCompleter = Completer<void>();
    });
  }

  void _fetchInitialData() {
    _nextPage = 1;
    MoonBlinkRepository.getUserPayments(_limit, _nextPage).then((value) async {
      _paymentsSubject.add(null);
      _nextPage++;
      _hasReachedMax = value.length < _limit;
      await Future.delayed(Duration(milliseconds: 50));
      _paymentsSubject.add(value);
    }, onError: (e) => _paymentsSubject.addError(e));
  }

  void _fetchMoreData() {
    if (_hasReachedMax || _isFetching) return;
    _isFetching = true;
    MoonBlinkRepository.getUserPayments(_limit, _nextPage).then((value) {
      _nextPage++;
      _hasReachedMax = value.length < _limit;
      _isFetching = false;
      _paymentsSubject.first.then((prev) {
        _paymentsSubject.add(prev + value);
      });
    }, onError: (e) {
      _hasReachedMax = true;
      _isFetching = false;
      _paymentsSubject.first.then((value) => _paymentsSubject.add(value));
    });
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        this._fetchMoreData();
      });
    }
  }

  Widget getPaymentStatus(int status) {
    if (status == PaymentStatus.PENDING.index) {
      return Text('Pending',
          style: TextStyle(color: Colors.blue, fontSize: 16.0));
    } else if (status == PaymentStatus.SUCCESS.index) {
      return Text('Success',
          style: TextStyle(color: Colors.green, fontSize: 16.0));
    } else if (status == PaymentStatus.REJECT.index) {
      return Text('Reject',
          style: TextStyle(color: Colors.red, fontSize: 16.0));
    } else if (status == PaymentStatus.REFUND.index) {
      return Text('Refund',
          style: TextStyle(color: Colors.amber, fontSize: 16.0));
    } else {
      return Text('Unknown',
          style: TextStyle(color: Colors.grey, fontSize: 16.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppbarWidget(title: Text(G.current.paymentHistory)),
        body: Container(
            margin: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              onRefresh: () {
                _refreshData();
                return _refreshCompleter.future;
              },
              child: StreamBuilder<List<Payment>>(
                initialData: null,
                stream: _paymentsSubject,
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return ViewStateErrorWidget(
                      error: ViewStateError(
                          snapshot.error == "No Internet Connection"
                              ? ViewStateErrorType.networkTimeOutError
                              : ViewStateErrorType.defaultError,
                          errorMessage: snapshot.error.toString()),
                      onPressed: () {
                        _paymentsSubject.add(null);
                        _refreshData();
                      },
                    );
                  if (snapshot.data == null) {
                    return Center(child: CupertinoActivityIndicator());
                  }
                  if (snapshot.data.isEmpty)
                    return Center(child: Text(G.current.paymentHistoryEmpty));
                  return ListView.builder(
                    //shrinkWrap: true,
                    controller: _scrollController,
                    physics: ClampingScrollPhysics(),
                    itemCount: _hasReachedMax
                        ? snapshot.data.length
                        : snapshot.data.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= snapshot.data.length) {
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: CupertinoActivityIndicator(),
                        ));
                      }
                      final item = snapshot.data[index];
                      return Card(
                        elevation: 10.0,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(child: () {
                                if (item.item.name == customProduct) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Product -> Custom Product'),
                                      SizedBox(height: 5),
                                      Text(
                                          'Transfer Amount -> ${item.transferAmount}'),
                                      SizedBox(height: 5),
                                      Text(
                                          'Description -> ${item.description}'),
                                      SizedBox(height: 5),
                                      if (item.note != null &&
                                          item.note.isNotEmpty)
                                        SizedBox(height: 5),
                                      if (item.note != null &&
                                          item.note.isNotEmpty)
                                        Text('Note -> ${item.note}'),
                                      // timeAgo.format(
                                      //     DateTime.parse(item.createdAt),
                                      //     allowFromNow: true),
                                      () {
                                        final date =
                                            DateTime.parse(item.createdAt);
                                        final day =
                                            date.day.toString().padLeft(2, '0');
                                        final month = date.month
                                            .toString()
                                            .padLeft(2, '0');
                                        final year = date.year.toString();
                                        return Text(
                                          'Purchased at ' + '$day/$month/$year',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12.0),
                                        );
                                      }()
                                    ],
                                  );
                                } else {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Product -> MoonBlink Coins - ${item.item.mbCoin}'),
                                      SizedBox(height: 5),
                                      Text(
                                          'Amount -> ${item.item.value} ${item.item.currencyCode}'),
                                      SizedBox(height: 5),
                                      if (item.note != null &&
                                          item.note.isNotEmpty)
                                        SizedBox(height: 5),
                                      if (item.note != null &&
                                          item.note.isNotEmpty)
                                        Text('Note -> ${item.note}'),
                                      Text(
                                        'Purchased at ' +
                                            timeAgo.format(
                                                DateTime.parse(item.createdAt),
                                                allowFromNow: true),
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12.0),
                                      )
                                    ],
                                  );
                                }
                              }()),
                              Center(
                                child: getPaymentStatus(item.status),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )),
      ),
    );
  }
}
