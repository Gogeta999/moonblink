import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/bloc_pattern/game_profile/bloc/game_profile_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/user_play_game.dart';

class ChooseUserPlayGamePage extends StatefulWidget {
  @override
  _ChooseUserPlayGamePageState createState() => _ChooseUserPlayGamePageState();
}

class _ChooseUserPlayGamePageState extends State<ChooseUserPlayGamePage> {
  final _gameProfileBloc = GameProfileBloc();

  @override
  void initState() {
    _gameProfileBloc.fetchGameProfile();
    super.initState();
  }

  @override
  void dispose() {
    _gameProfileBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(),
      body: SafeArea(
        child: StreamBuilder<UserPlayGameList>(
          initialData: null,
          stream: _gameProfileBloc.userPlayGameListSubject,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: CupertinoButton(
                    child: Text('Something went wrong! Retry'),
                    onPressed: () {
                      _gameProfileBloc.fetchGameProfile();
                      _gameProfileBloc.userPlayGameListSubject.add(null);
                    }),
              );
            } else if (snapshot.data == null) {
              return Center(child: CupertinoActivityIndicator());
            } else if (snapshot.hasData &&
                snapshot.data.userPlayGameList.isNotEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data.userPlayGameList.length,
                itemBuilder: (context, index) {
                  UserPlayGame item = snapshot.data.userPlayGameList[index];
                  return Slidable(
                    enabled: item.isPlay == 0
                        ? false
                        : true,
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    secondaryActions: <Widget>[
                      Card(
                        elevation: 8,
                        child: StreamBuilder<DeselectState>(
                            stream: _gameProfileBloc.deselectSubject.stream,
                            builder: (context, snapshot) {
                              return IconSlideAction(
                                closeOnTap: false,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                caption: snapshot.data == DeselectState.loading
                                    ? G.of(context).loading
                                    : G.of(context).deselect,
                                iconWidget: snapshot.data ==
                                        DeselectState.loading
                                    ? CupertinoActivityIndicator()
                                    : Icon(Icons.remove_circle,
                                        color: Theme.of(context).accentColor),
                                onTap: () =>
                                    snapshot.data == DeselectState.loading
                                        ? {}
                                        : _gameProfileBloc.onTapDeselect(item),
                              );
                            }),
                      )
                    ],
                    child: Card(
                      elevation: 8,
                      child: ListTile(
                        onTap: () => _gameProfileBloc.onTapListTile(
                            item, _gameProfileBloc),
                        leading: CachedNetworkImage(
                          imageUrl: item.gameIcon,
                          imageBuilder: (context, imageProvider) => Container(
                            width: 46.0,
                            height: 46.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (context, url) =>
                              CupertinoActivityIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                        title: Text(item.name),
                        subtitle:
                            item.description == null || item.description.isEmpty
                                ? null
                                : Text(item.description),
                        trailing: Icon(
                          Icons.check_box,
                          color: item.isPlay == 0
                              ? Colors.transparent
                              : Theme.of(context).accentColor,
                        ),
                        selected: item.isPlay == 0
                            ? false
                            : true,
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text(G.of(context).toasterror));
            }
          },
        ),
      ),
    );
  }
}
