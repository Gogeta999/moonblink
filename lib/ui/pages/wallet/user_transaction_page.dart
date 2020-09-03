import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moonblink/base_widget/profile_widgets.dart';
import 'package:moonblink/bloc_pattern/user_transaction/bloc.dart';

class UserTransactionPage extends StatefulWidget {
  @override
  _UserTransactionPageState createState() => _UserTransactionPageState();
}

class _UserTransactionPageState extends State<UserTransactionPage> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  Completer<void> _refreshCompleter;
  //final _refreshController = RefreshController();
  final userTransactionBloc = UserTransactionBloc();

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    _refreshCompleter = Completer<void>();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<UserTransactionBloc>(
      create: (_) => userTransactionBloc..add(UserTransactionFetched()),
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: BlocConsumer<UserTransactionBloc, UserTransactionState>(
          listener: (context, state) {
            if (state is UserTransactionSuccess) {
              _refreshCompleter.complete();
              _refreshCompleter = Completer();
            }
            if (state is UserTransactionFailure) {
              _refreshCompleter.completeError(state.error);
              _refreshCompleter = Completer();
            }
          },
          builder: (context, state) {
            if (state is UserTransactionInitial) {
              return Center(
                child: CupertinoActivityIndicator(),
              );
            }
            if (state is UserTransactionFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Error: ${state.error}.'),
                    RaisedButton(
                      onPressed: _onRefresh,
                      child: Text('Retry'),
                    )
                  ],
                ),
              );
            }
            if (state is UserTransactionNoData) {
              return Center(
                child: Text('This user has no history.'),
              );
            }
            if (state is UserTransactionSuccess) {
              if (state.data.isEmpty) {
                return Center(
                  child: Text('This user has no history.'),
                );
              }
              return ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return index >= state.data.length
                      ? BottomLoader()
                      : HistoryWidget(history: state.data[index]);
                },
                itemCount: state.hasReachedMax
                    ? state.data.length
                    : state.data.length + 1,
                controller: _scrollController,
              );
            }
            return Text('Oops!. Something went wrong.');
          },
        ),
      ),
    );
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      userTransactionBloc.add(UserTransactionFetched());
    }
  }

  Future<void> _onRefresh() {
    userTransactionBloc.add(UserTransactionRefreshed());
    return _refreshCompleter.future;
  }
}
