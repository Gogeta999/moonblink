import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/profile_widgets.dart';
import 'package:moonblink/bloc_pattern/user_notification/user_notification_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/user_notification.dart';
import 'package:moonblink/provider/view_state.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:moonblink/ui/pages/main/notifications/booking_request_detail_page.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class UserNotificationPage extends StatefulWidget {
  @override
  _UserNotificationPageState createState() => _UserNotificationPageState();
}

class _UserNotificationPageState extends State<UserNotificationPage>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final _scrollThreshold = 600.0;
  Completer<void> _refreshCompleter;
  UserNotificationBloc _userNotificationBloc;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _userNotificationBloc = BlocProvider.of<UserNotificationBloc>(context);
    _userNotificationBloc.add(UserNotificationFetched());
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          AppbarLogo(),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: BlocProvider.value(
              value: _userNotificationBloc,
              //create: (_) =>
              //_userNotificationBloc..add(UserNotificationFetched()),
              child: BlocConsumer<UserNotificationBloc, UserNotificationState>(
                buildWhen: (previousState, currentState) =>
                currentState != UserNotificationAcceptStateToInitial() &&
                    currentState != UserNotificationRejectStateToInitial()
                ,
                listener: (context, state) {
                  if (state is UserNotificationSuccess) {
                    _refreshCompleter.complete();
                    _refreshCompleter = Completer();
                  }
                  if (state is UserNotificationFailure) {
                    _refreshCompleter.completeError(state.error);
                    _refreshCompleter = Completer();
                  }
                },
                builder: (context, state) {
                  if (state is UserNotificationInitial) {
                    return Center(child: CupertinoActivityIndicator());
                  }
                  if (state is UserNotificationFailure) {
                    print('${state.error}');
                    return ViewStateErrorWidget(
                      error: ViewStateError(
                        ViewStateErrorType.networkTimeOutError,
                        errorMessage: 'Oops! Something went wrong!',
                      ),
                      onPressed: () => _userNotificationBloc
                          .add(UserNotificationRefreshed()),
                    );
                  }
                  if (state is UserNotificationSuccess) {
                    if (state.data.isEmpty) {
                      return ListView(
                        physics: ScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(
                                parent: ClampingScrollPhysics())),
                        children: [
                          SizedBox(
                            height: 220,
                          ),
                          Center(
                            child: Text(
                              'You have no notifications',
                              style: TextStyle(fontSize: 20),
                            ),
                          )
                        ],
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.all(10),
                      physics: ScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(
                              parent: ClampingScrollPhysics())),
                      itemBuilder: (BuildContext context, int index) {
                        return index >= state.data.length
                            ? BottomLoader()
                            : BlocProvider.value(
                                value: BlocProvider.of<UserNotificationBloc>(
                                    context),
                                child: NotificationListTile(index: index));
                      },
                      itemCount: state.hasReachedMax
                          ? state.data.length
                          : state.data.length + 1,
                      controller: _scrollController,
                    );
                  }
                  return Center(child: Text(G.of(context).toasterror));
                },
              )),
        ),
      ),
    );
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _userNotificationBloc.add(UserNotificationFetched());
    }
  }

  Future<void> _onRefresh() {
    _userNotificationBloc.add(UserNotificationRefreshed());
    return _refreshCompleter.future;
  }
}

class NotificationListTile extends StatelessWidget {
  final int index;

  const NotificationListTile({Key key, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserNotificationBloc, UserNotificationState>(
      buildWhen: (previousState, currentState) =>
      currentState != UserNotificationAcceptStateToInitial() &&
          currentState != UserNotificationRejectStateToInitial()
      ,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is UserNotificationSuccess) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: state.data[index].isRead != 0
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Theme.of(context).accentColor.withOpacity(0.5),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  spreadRadius: 0.5,
                  // blurRadius: 2,
                  offset: Offset(-3, 3), // changes position of shadow
                ),
              ],
            ),
            child: ListTile(
              onTap: () => _onTapListTile(context, state.data[index]),
              title: Text(state.data[index].title,

                  ///add game name and type later
                  style: Theme.of(context).textTheme.bodyText2),
              subtitle: Text(state.data[index].message,
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.chevron_right),
                  Text(
                  timeAgo.format(DateTime.parse(state.data[index].createdAt),
                    allowFromNow: true), style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
                ]
              )
            ),
          );
        }
        return Text('Something went wrong!');
      },
    );
  }

  _onTapListTile(BuildContext context, UserNotificationData data) {
    // Map<String, int> arguments = {
    //   'index': index,
    //   'notificationId': data.id
    // };
    BlocProvider.of<UserNotificationBloc>(context)
        .add(UserNotificationChangeToRead(data.id));
    //Navigator.pushNamed(context, RouteName.bookingRequestDetailPage, arguments: arguments);
    //if (data.isRead != 0) return;
    //now navigate to next page
    // final cancel = CupertinoActionSheetAction(
    //     onPressed: () => Navigator.pop(context),
    //     child: Text('Cancel')
    // );
    // final accept = CupertinoActionSheetAction(
    //     onPressed: () {
    //       BlocProvider.of<UserNotificationBloc>(context).add(
    //           UserNotificationAccepted(data.fcmData.userId, data.fcmData.id,
    //               data.fcmData.bookingUserId));
    //       Navigator.pop(context);
    //     },
    //     child: Text('Accept'),
    //     isDefaultAction: true);
    // final reject = CupertinoActionSheetAction(
    //     onPressed: () {
    //       BlocProvider.of<UserNotificationBloc>(context).add(
    //           UserNotificationRejected(data.fcmData.userId, data.fcmData.id));
    //       Navigator.pop(context);
    //     },
    //     child: Text('Reject'));
    // showCupertinoModalPopup(
    //     context: context,
    //     builder: (context) {
    //       return CupertinoActionSheet(
    //           actions: [accept, reject], cancelButton: cancel);
    //     });
  }
}
