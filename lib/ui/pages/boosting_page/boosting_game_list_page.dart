import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/bloc_pattern/game_profile/bloc/game_profile_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/user_play_game.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:rxdart/subjects.dart';

class BoostingGameListPage extends StatefulWidget {
  @override
  _BoostingGameListPageState createState() => _BoostingGameListPageState();
}

class _BoostingGameListPageState extends State<BoostingGameListPage> {
  ///ViewModel and Controller in one page coz its simple
  final _bookingGameListSubject = BehaviorSubject<List<UserPlayGame>>.seeded(null);
  final deselectSubject = BehaviorSubject.seeded(DeselectState.initial);

  @override
  void initState() {
    MoonBlinkRepository.getUserPlayGameList().then((value) {
      final List<UserPlayGame> data = [];
      value.userPlayGameList.forEach((element) {
        if (element.isBoostable == 1) data.add(element);
      });
      _bookingGameListSubject.add(data);
    }, onError: (e) => _bookingGameListSubject.addError(e));
    super.initState();
  }

  @override
  void dispose() {
    _bookingGameListSubject.close();
    deselectSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Scaffold(
        appBar: AppbarWidget(),
        body: StreamBuilder<List<UserPlayGame>>(
          initialData: null,
          stream: _bookingGameListSubject,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint(snapshot.error.toString());
              return Center(child: Text('Something Went Wrong!'));
            }
            if (snapshot.data == null) {
              return Center(child: CupertinoActivityIndicator());
            }
            if (snapshot.data.isEmpty) {
              return Center(child: Text('No Data To Show!!'));
            }
            return ListView.builder(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  UserPlayGame item = snapshot.data[index];
                  return Slidable(
                    // enabled: item.isPlay == 0
                    //     ? false
                    //     : true,
                    enabled: false,///false for now no flag include in response
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    secondaryActions: <Widget>[
                      Card(
                        elevation: 8,
                        child: StreamBuilder<DeselectState>(
                            stream: deselectSubject.stream,
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
                                        : {},//_gameProfileBloc.onTapDeselect(item),
                              );
                            }),
                      )
                    ],
                    child: Card(
                      elevation: 8,
                      child: ListTile(
                        onTap: () => onTapListTile(item),
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
                          color: true//item.isPlay == 0
                              ? Colors.transparent
                              : Theme.of(context).accentColor,
                        ),
                        selected: false,
                        // selected: item.isPlay == 0
                        //     ? false
                        //     : true,
                      ),
                    ),
                  );
                },
              );

          },
        )
      ),
    );
  }

  // void onTapDeselect(UserPlayGame item) {
  //   ///call delete api
  //   deselectSubject.add(DeselectState.loading);
  //   MoonBlinkRepository.deleteGameProfile(item.gameProfile.gameId).then(
  //       (value) {
  //     deselectSubject.add(DeselectState.initial);
  //     StorageManager.sharedPreferences.setInt(mgameprofile,
  //         StorageManager.sharedPreferences.getInt(mgameprofile) - 1);
  //     print("GAMEPROFILE COUNT IS " +
  //         StorageManager.sharedPreferences.getInt(mgameprofile).toString());

  //     ///After delete, fetch data from server again
  //     this.fetchGameProfile();
  //   }, onError: (err) {
  //     deselectSubject.add(DeselectState.initial);
  //     showToast(err.toString());
  //   });
  // }

  void onTapListTile(UserPlayGame item) {
    Navigator.pushNamed(context, RouteName.boostingGameDetailPage, arguments: {'id': item.id, 'game_name': item.name}).then((value) {
       if (value != null && value) 
        MoonBlinkRepository.getUserPlayGameList().then((value) {
      final List<UserPlayGame> data = [];
      value.userPlayGameList.forEach((element) {
        if (element.isBoostable == 1) data.add(element);
      });
      _bookingGameListSubject.add(data);
    }, onError: (e) => _bookingGameListSubject.addError(e));
    });
  }
}