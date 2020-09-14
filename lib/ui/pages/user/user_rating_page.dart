import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/profile_widgets.dart';
import 'package:moonblink/bloc_pattern/user_rating/user_rating_bloc.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:intl/intl.dart';

class UserRatingPage extends StatefulWidget {
  final int userId;

  const UserRatingPage({Key key, this.userId}) : super(key: key);
  @override
  _UserRatingPageState createState() => _UserRatingPageState();
}

class _UserRatingPageState extends State<UserRatingPage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 600.0;
  Completer<void> _refreshCompleter;
  UserRatingBloc _usersRatingBloc;

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
      appBar: AppBar(
        title: Text('User Rating'),
        backgroundColor: Colors.black,
        actions: [
          AppbarLogo(),
        ],
      ),
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
                        child: Text('This user has no rating.'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      shrinkWrap: true,
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
                  return Center(child: Text('Oops Something went wrong!'));
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

  const RatingListTile({Key key, this.state, this.index})
      : assert(state != null && index != null && index >= 0),
        super(key: key);

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
            color: Theme.of(context).accentColor,
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
          title: Text(state.data[index].name),
          subtitle: Text(state.data[index].comment),
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
