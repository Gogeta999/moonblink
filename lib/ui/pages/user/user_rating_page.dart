import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moonblink/base_widget/profile_widgets.dart';
import 'package:moonblink/bloc_pattern/user_rating/user_rating_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:intl/intl.dart';

class UserRatingPage extends StatefulWidget {
  final int userId;

  const UserRatingPage({Key key, this.userId}) : super(key: key);
  @override
  _UserRatingPageState createState() => _UserRatingPageState();
}

class _UserRatingPageState extends State<UserRatingPage>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  Completer<void> _refreshCompleter;
  UserRatingBloc _usersRatingBloc;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _usersRatingBloc = UserRatingBloc(widget.userId);
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
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('User Rating'),
      //   backgroundColor: Colors.black,
      //   actions: [
      //     AppbarLogo(),
      //   ],
      // ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: BlocProvider(
              create: (_) => _usersRatingBloc..add(UserRatingFetched()),
              child: BlocConsumer<UserRatingBloc, UserRatingState>(
                listener: (context, state) {
                  if (state is UserRatingSuccess) {
                    _refreshCompleter.complete();
                    _refreshCompleter = Completer();
                  }
                  if (state is UserRatingFailure) {
                    _refreshCompleter.completeError(state.error);
                    _refreshCompleter = Completer();
                  }
                },
                builder: (context, state) {
                  if (state is UserRatingInitial) {
                    return Center(child: CupertinoActivityIndicator());
                  }
                  if (state is UserRatingFailure) {
                    return Center(child: Text('Error: ${state.error}'));
                  }
                  if (state is UserRatingRefreshing) {
                    return Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('Refreshing...'),
                        SizedBox(width: 5),
                        CupertinoActivityIndicator()
                      ],
                    ));
                  }
                  if (state is UserRatingSuccess) {
                    if (state.data.isEmpty) {
                      return Center(
                        child: Text(G.of(context).norating),
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
                            : RatingListTile(state: state, index: index);
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
      _usersRatingBloc.add(UserRatingFetched());
    }
  }

  Future<void> _onRefresh() {
    _usersRatingBloc.add(UserRatingRefreshed());
    return _refreshCompleter.future;
  }
}

class RatingListTile extends StatelessWidget {
  final UserRatingSuccess state;
  final int index;

  RatingListTile({Key key, this.state, this.index})
      : assert(state != null && index != null && index >= 0),
        super(key: key);

  ///false means unexpanded
  final BehaviorSubject<bool> _expandIconSubject =
      BehaviorSubject.seeded(false);

  _onTapExpandIcon() {
    _expandIconSubject.first.then((value) {
      _expandIconSubject.add(!value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
          onTap: () => Navigator.pushNamed(context, RouteName.partnerDetail,
              arguments: state.data[index].ratingUserId),
          leading: CachedNetworkImage(
            imageUrl: state.data[index].profileImage,
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: 28,
              backgroundImage: imageProvider,
            ),
            fit: BoxFit.cover,
            placeholder: (context, url) => CachedLoader(),
            errorWidget: (context, url, error) => CachedError(),
          ),
          title: Container(
            margin: const EdgeInsets.symmetric(vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(state.data[index].name,
                    style: Theme.of(context).textTheme.button),
                InkWell(
                  onTap: _onTapExpandIcon,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                            '${state.data[index].comment.isEmpty ? 'No Comment' : 'Commented'}',
                            style: Theme.of(context).textTheme.button),
                      ),
                      SizedBox(width: 5),
                      if (state.data[index].comment.isNotEmpty)
                        StreamBuilder<bool>(
                            initialData: false,
                            stream: _expandIconSubject.stream,
                            builder: (context, snapshot) {
                              return snapshot.data
                                  ? Icon(Icons.expand_less)
                                  : Icon(Icons.expand_more);
                            }),
                    ],
                  ),
                )
              ],
            ),
          ),
          subtitle: StreamBuilder<bool>(
              initialData: false,
              stream: _expandIconSubject.stream,
              builder: (context, snapshot) {
                if (state.data[index].comment.isNotEmpty && snapshot.data) {
                  return Text('\"' + state.data[index].comment + '\"',
                      style:
                          TextStyle(fontSize: 14, fontStyle: FontStyle.italic));
                } else {
                  return Container();
                }
              }),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SmoothStarRating(
                  color: Theme.of(context).accentColor,
                  isReadOnly: true,
                  starCount: 5,
                  rating: state.data[index].star,
                  size: 20),
              SizedBox(height: 5),
              Text(DateFormat.yMd()
                  .format(DateTime.parse(state.data[index].updatedAt)))
            ],
          )),
    );
  }
}
