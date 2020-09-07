import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/user_play_game.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:oktoast/oktoast.dart';

class ChooseUserPlayGamePage extends StatefulWidget {
  @override
  _ChooseUserPlayGamePageState createState() => _ChooseUserPlayGamePageState();
}

class _ChooseUserPlayGamePageState extends State<ChooseUserPlayGamePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose game you play'),
      ),
      body: FutureBuilder<UserPlayGameList>(
        future: MoonBlinkRepository.getUserPlayGameList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data.userPlayGameList.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              physics: ClampingScrollPhysics(),
              itemCount: snapshot.data.userPlayGameList.length,
              itemBuilder: (context, index) {
                UserPlayGame item = snapshot.data.userPlayGameList[index];
                return Card(
                  child: ListTile(
                    onTap: () =>
                        Navigator.pushNamed(context, RouteName.updateGameProfile, arguments: item.gameProfile),
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
                      placeholder: (context, url) => CupertinoActivityIndicator(),
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
                );
              },
            );
          } else {
            return Center(child: Text('Something went wrong!'));
          }
        },
      ),
    );
  }
}
