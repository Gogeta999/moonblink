import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/profile_widgets.dart';
import 'package:moonblink/bloc_pattern/user_notification/new/user_new_notification_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/notification_models/user_new_notification.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class UserNewNotificationPage extends StatefulWidget {
  @override
  _UserNewNotificationPageState createState() =>
      _UserNewNotificationPageState();
}

class _UserNewNotificationPageState extends State<UserNewNotificationPage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 600.0;
  Completer<void> _refreshCompleter;
  UserNewNotificationBloc _userNotificationBloc;

  @override
  void initState() {
    _userNotificationBloc = BlocProvider.of<UserNewNotificationBloc>(context);
    _userNotificationBloc.add(UserNewNotificationFetched());
    _scrollController.addListener(_onScroll);
    _refreshCompleter = Completer<void>();
    print('Initing');
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        children: [
          Card(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: ListTile(
              leading: Icon(
                Icons.settings_applications,
                size: 50,
              ),
              onTap: () =>
                  Navigator.pushNamed(context, RouteName.userMessageHistory),
              // isThreeLine: true,
              title: Text(
                'Moon Go History',
                style: Theme.of(context).textTheme.headline6,
              ),
              subtitle: Text(''),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(
                FontAwesomeIcons.book,
                size: 50,
              ),
              onTap: () =>
                  Navigator.pushNamed(context, RouteName.userBookingHistory),
              title: Text(
                'Booking History',
                style: Theme.of(context).textTheme.headline6,
              ),
              subtitle: Text(''),
            ),
          ),
          BlocProvider.value(
              value: _userNotificationBloc,
              child: BlocConsumer<UserNewNotificationBloc,
                  UserNewNotificationState>(
                listener: (context, state) {
                  if (state is UserNewNotificationSuccess) {
                    _refreshCompleter.complete();
                    _refreshCompleter = Completer();
                  }
                  if (state is UserNewNotificationFailure) {
                    _refreshCompleter.completeError(state.error);
                    _refreshCompleter = Completer();
                  }
                },
                buildWhen: (previousState, currentState) =>
                    currentState != UserNewNotificationDeleteSuccess() &&
                    currentState != UserNewNotificationDeleteFailure(),
                builder: (context, state) {
                  if (state is UserNewNotificationInitial) {
                    return SizedBox(
                        height: 220,
                        child: Center(child: CupertinoActivityIndicator()));
                  }
                  if (state is UserNewNotificationFailure) {
                    print('${state.error}');
                    return SizedBox(
                      height: 220,
                      child: Center(
                        child: Text(
                          'You have no notifications',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    );
                  }
                  if (state is UserNewNotificationNoData) {
                    return SizedBox(
                      height: 220,
                      child: Center(
                        child: Text(
                          'You have no notifications',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    );
                  }
                  if (state is UserNewNotificationSuccess) {
                    if (state.data.isEmpty) {
                      return SizedBox(
                        height: 220,
                        child: Center(
                          child: Text(
                            'You have no notifications',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(10),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return index >= state.data.length
                            ? BottomLoader()
                            : BlocProvider.value(
                                value: BlocProvider.of<UserNewNotificationBloc>(
                                    context),
                                child: NotificationListTile(index: index));
                      },
                      itemCount: state.hasReachedMax
                          ? state.data.length
                          : state.data.length + 1,
                      //controller: _scrollController,
                    );
                  }

                  ///Same with success
                  if (state is UserNewNotificationUpdating) {
                    if (state.data.isEmpty) {
                      return SizedBox(
                        height: 220,
                        child: Center(
                          child: Text(
                            'You have no notifications',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(10),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return index >= state.data.length
                            ? BottomLoader()
                            : BlocProvider.value(
                                value: BlocProvider.of<UserNewNotificationBloc>(
                                    context),
                                child: NotificationListTile(index: index));
                      },
                      itemCount: state.hasReachedMax
                          ? state.data.length
                          : state.data.length + 1,
                      //controller: _scrollController,
                    );
                  }
                  return Center(child: Text(G.of(context).toasterror));
                },
              )),
        ],
      ),
    );
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _userNotificationBloc.add(UserNewNotificationFetched());
    }
  }

  Future<void> _onRefresh() {
    _userNotificationBloc.add(UserNewNotificationRefreshed());
    return _refreshCompleter.future;
  }
}

enum DeleteState { initial, loading }

class NotificationListTile extends StatelessWidget {
  final int index;

  NotificationListTile({Key key, this.index}) : super(key: key);

  final _deleteSubject = BehaviorSubject.seeded(DeleteState.initial);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserNewNotificationBloc, UserNewNotificationState>(
      listener: (context, state) {
        if (state is UserNewNotificationDeleteSuccess) {
          _deleteSubject.add(DeleteState.initial);
        }
        if (state is UserNewNotificationDeleteFailure) {
          showToast('${state.error}');
          _deleteSubject.add(DeleteState.initial);
        }
      },
      buildWhen: (previousState, currentState) =>
          currentState != UserNewNotificationDeleteSuccess() &&
          currentState != UserNewNotificationDeleteFailure(),
      builder: (context, state) {
        ///Same with update
        if (state is UserNewNotificationSuccess) {
          return Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              secondaryActions: <Widget>[
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: state.data[index].isRead != 0
                        ? Theme.of(context).scaffoldBackgroundColor
                        : Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(10),
                    // color: Colors.pink,
                    border: Border.all(color: Colors.black),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black,
                    //     spreadRadius: 0.5,
                    //     // blurRadius: 2,
                    //     offset: Offset(-3, 3), // changes position of shadow
                    //   ),
                    // ],
                  ),
                  child: Card(
                    child: IconSlideAction(
                      closeOnTap: true,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      iconWidget: Icon(Icons.delete,
                          color: Theme.of(context).accentColor),
                      onTap: () => _onTapDelete(context, state.data[index]),
                    ),
                  ),
                )
              ],
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: () {
                    if (state.data[index].isRead != 0) {
                      return Theme.of(context).scaffoldBackgroundColor;
                    } else {
                      return Theme.of(context).accentColor;
                    }
                  }(),
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black,
                  //     spreadRadius: 0.5,
                  //     // blurRadius: 2,
                  //     offset: Offset(-3, 3), // changes position of shadow
                  //   ),
                  // ],
                ),
                child: Card(
                  child: InkWell(
                    child: StreamBuilder<DeleteState>(
                        initialData: DeleteState.initial,
                        stream: _deleteSubject,
                        builder: (context, snapshot) {
                          return ListTile(
                              onTap: () =>
                                  _onTapListTile(context, state.data[index]),
                              title: Text(state.data[index].title,

                                  ///add game name and type later
                                  style: Theme.of(context).textTheme.bodyText2),
                              subtitle: Text(state.data[index].message,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic)),
                              trailing: snapshot.data == DeleteState.loading
                                  ? CupertinoActivityIndicator()
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                          Icon(Icons.chevron_right),
                                          Text(
                                              timeAgo.format(
                                                  DateTime.parse(state
                                                      .data[index].createdAt),
                                                  allowFromNow: true),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic))
                                        ]));
                        }),
                  ),
                ),
              ));
        }
        if (state is UserNewNotificationUpdating) {
          return Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              secondaryActions: <Widget>[
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: state.data[index].isRead != 0
                        ? Theme.of(context).scaffoldBackgroundColor
                        : Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(10),
                    // color: Colors.pink,
                    border: Border.all(color: Colors.black),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black,
                    //     spreadRadius: 0.5,
                    //     // blurRadius: 2,
                    //     offset: Offset(-3, 3), // changes position of shadow
                    //   ),
                    // ],
                  ),
                  child: Card(
                    child: IconSlideAction(
                      closeOnTap: true,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      iconWidget: Icon(Icons.delete,
                          color: Theme.of(context).accentColor),
                      onTap: () => _onTapDelete(context, state.data[index]),
                    ),
                  ),
                )
              ],
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: () {
                    if (state.data[index].isRead != 0) {
                      return Theme.of(context).scaffoldBackgroundColor;
                    } else {
                      return Theme.of(context).accentColor;
                    }
                  }(),
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black,
                  //     spreadRadius: 0.5,
                  //     // blurRadius: 2,
                  //     offset: Offset(-3, 3), // changes position of shadow
                  //   ),
                  // ],
                ),
                child: Card(
                  child: InkWell(
                    child: StreamBuilder<DeleteState>(
                        initialData: DeleteState.initial,
                        stream: _deleteSubject,
                        builder: (context, snapshot) {
                          return ListTile(
                              onTap: () =>
                                  _onTapListTile(context, state.data[index]),
                              title: Text(state.data[index].title,

                                  ///add game name and type later
                                  style: Theme.of(context).textTheme.bodyText2),
                              subtitle: Text(state.data[index].message,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic)),
                              trailing: snapshot.data == DeleteState.loading
                                  ? CupertinoActivityIndicator()
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                          Icon(Icons.chevron_right),
                                          Text(
                                              timeAgo.format(
                                                  DateTime.parse(state
                                                      .data[index].createdAt),
                                                  allowFromNow: true),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic))
                                        ]));
                        }),
                  ),
                ),
              ));
        }
        return Text('Something went wrong!');
      },
    );
  }

  _onTapListTile(BuildContext context, UserNewNotificationData data) async {
    BlocProvider.of<UserNewNotificationBloc>(context)
        .add(UserNewNotificationChangeToRead(data.id));
  }

  _onTapDelete(BuildContext context, UserNewNotificationData data) {
    ///call delete api
    _deleteSubject.add(DeleteState.loading);
    try {
      BlocProvider.of<UserNewNotificationBloc>(context)
          .add(UserNewNotificationDelete(data.id));
    } catch (_) {
      _deleteSubject.add(DeleteState.initial);
    }
  }
}
