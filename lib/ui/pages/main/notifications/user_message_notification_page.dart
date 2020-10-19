import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/profile_widgets.dart';
import 'package:moonblink/bloc_pattern/user_notification/message/user_message_notification_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/notification_models/user_message_notification.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class UserMessageNotificationPage extends StatefulWidget {
  @override
  _UserMessageNotificationPageState createState() =>
      _UserMessageNotificationPageState();
}

class _UserMessageNotificationPageState
    extends State<UserMessageNotificationPage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 600.0;
  Completer<void> _refreshCompleter;
  UserMessageNotificationBloc _userNotificationBloc;

  @override
  void initState() {
    _userNotificationBloc = UserMessageNotificationBloc();
    _userNotificationBloc.add(UserMessageNotificationFetched());
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
      appBar: AppbarWidget(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: BlocProvider.value(
            value: _userNotificationBloc,
            //create: (_) =>
            //_userNotificationBloc..add(UserNotificationFetched()),
            child: BlocConsumer<UserMessageNotificationBloc,
                UserMessageNotificationState>(
              listener: (context, state) {
                if (state is UserMessageNotificationSuccess) {
                  _refreshCompleter.complete();
                  _refreshCompleter = Completer();
                }
                if (state is UserMessageNotificationFailure) {
                  _refreshCompleter.completeError(state.error);
                  _refreshCompleter = Completer();
                }
              },
              builder: (context, state) {
                if (state is UserMessageNotificationInitial) {
                  return Center(child: CupertinoActivityIndicator());
                }
                if (state is UserMessageNotificationFailure) {
                  print('${state.error}');
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
                if (state is UserMessageNotificationNoData) {
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
                if (state is UserMessageNotificationSuccess) {
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
                              value:
                                  BlocProvider.of<UserMessageNotificationBloc>(
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
    );
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _userNotificationBloc.add(UserMessageNotificationFetched());
    }
  }

  Future<void> _onRefresh() {
    _userNotificationBloc.add(UserMessageNotificationRefreshed());
    return _refreshCompleter.future;
  }
}

class NotificationListTile extends StatelessWidget {
  final int index;

  const NotificationListTile({Key key, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserMessageNotificationBloc,
        UserMessageNotificationState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is UserMessageNotificationSuccess) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: state.data[index].isRead != 0
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Theme.of(context).accentColor,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Card(
              child: InkWell(
                child: ListTile(
                    onTap: () => _onTapListTile(context, state.data[index]),
                    title: Text(state.data[index].title,

                        ///add game name and type later
                        style: Theme.of(context).textTheme.bodyText2),
                    subtitle: Text(state.data[index].message,
                        style: TextStyle(
                            fontSize: 12, fontStyle: FontStyle.italic)),
                    trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(Icons.chevron_right),
                          Text(
                              timeAgo.format(
                                  DateTime.parse(state.data[index].createdAt),
                                  allowFromNow: true),
                              style: TextStyle(
                                  fontSize: 12, fontStyle: FontStyle.italic))
                        ])),
              ),
            ),
          );
        }
        return Text('Something went wrong!');
      },
    );
  }

  _onTapListTile(BuildContext context, UserMessageNotificationData data) {
    BlocProvider.of<UserMessageNotificationBloc>(context)
        .add(UserMessageNotificationChangeToRead(data.id));
  }
}
