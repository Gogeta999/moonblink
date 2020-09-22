import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/user_play_game.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

enum DeselectState { initial, loading }

class ChooseUserPlayGamePage extends StatefulWidget {
  @override
  _ChooseUserPlayGamePageState createState() => _ChooseUserPlayGamePageState();
}

class _ChooseUserPlayGamePageState extends State<ChooseUserPlayGamePage> {
  BehaviorSubject<DeselectState> _deselectSubject = BehaviorSubject()
    ..add(DeselectState.initial);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(G.of(context).choosegame),
        leading: IconButton(
            icon: Icon(CupertinoIcons.back),
            onPressed: () {
              Navigator.pop(context);
            }),
        // elevation: 15,
        // shadowColor: Colors.blue,
        bottom: PreferredSize(
            child: Container(
              height: 10,
              color: Theme.of(context).accentColor,
            ),
            preferredSize: Size.fromHeight(10)),
      ),
      backgroundColor: Colors.grey[200],
      body: FutureBuilder<UserPlayGameList>(
        future: MoonBlinkRepository.getUserPlayGameList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          } else if (snapshot.hasData &&
              snapshot.data.userPlayGameList.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              physics: ClampingScrollPhysics(),
              itemCount: snapshot.data.userPlayGameList.length,
              itemBuilder: (context, index) {
                UserPlayGame item = snapshot.data.userPlayGameList[index];
                return Slidable(
                  enabled: item.isPlay == 0 ? false : true,
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  secondaryActions: <Widget>[
                    Card(
                      elevation: 8,
                      child: StreamBuilder<DeselectState>(
                          stream: _deselectSubject.stream,
                          builder: (context, snapshot) {
                            return IconSlideAction(
                              closeOnTap: false,
                              color: Theme.of(context).scaffoldBackgroundColor,
                              caption: snapshot.data == DeselectState.loading
                                  ? G.of(context).loading
                                  : G.of(context).deselect,
                              iconWidget: snapshot.data == DeselectState.loading
                                  ? CupertinoActivityIndicator()
                                  : Icon(Icons.remove_circle,
                                      color: Theme.of(context).accentColor),
                              onTap: () =>
                                  snapshot.data == DeselectState.loading
                                      ? {}
                                      : _onTapDeselect(item),
                            );
                          }),
                    )
                  ],
                  child: Card(
                    elevation: 8,
                    child: ListTile(
                      onTap: () => _onTapListTile(item),
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
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      title: Text(item.name),
                      subtitle: Text(item.description),
                      trailing: Icon(
                        Icons.check_box,
                        color: item.isPlay == 0
                            ? Colors.transparent
                            : Theme.of(context).accentColor,
                      ),
                      selected: item.isPlay == 0 ? false : true,
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
    );
  }

  _onTapListTile(UserPlayGame item) {
    Navigator.pushNamed(context, RouteName.updateGameProfile,
            arguments: item.gameProfile)
        .then((value) {
      if (value != null && value) setState(() {});
    });
  }

  _onTapDeselect(UserPlayGame item) {
    ///call delete api
    _deselectSubject.add(DeselectState.loading);
    MoonBlinkRepository.deleteGameProfile(item.gameProfile.gameId).then(
        (value) {
      _deselectSubject.add(DeselectState.initial);

      ///After delete, fetch data from server again
      setState(() {});
    }, onError: (err) {
      _deselectSubject.add(DeselectState.initial);
      showToast(err.toString());
    });
  }
}
