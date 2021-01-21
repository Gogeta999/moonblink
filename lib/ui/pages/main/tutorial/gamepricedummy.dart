import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/base_widget/game_mode_bottom_sheet.dart';
import 'package:moonblink/base_widget/intro/flutter_intro.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/game_profile.dart';
import 'package:moonblink/ui/helper/tutorial.dart';
import 'package:moonblink/ui/pages/main/tutorial/homepagedummy.dart';

class GamePriceDummy extends StatefulWidget {
  GamePriceDummy({Key key}) : super(key: key);

  @override
  _GamePriceDummyState createState() => _GamePriceDummyState();
}

class _GamePriceDummyState extends State<GamePriceDummy> {
  Intro intro;

  _GamePriceDummyState() {
    intro = Intro(
      stepCount: 1,
      borderRadius: BorderRadius.circular(15),
      onfinish: () {
        intro.dispose();
        Future.delayed(
          Duration(microseconds: 0),
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePageDummy(),
              ),
            );
          },
        );
      },

      /// use defaultTheme, or you can implement widgetBuilder function yourself
      widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        texts: [
          G.of(context).tutogameprice1,
        ],
        buttonTextBuilder: (curr, total) {
          return curr < total - 1 ? G.of(context).next : G.of(context).finish;
        },
      ),
    );
  }

  List<GameMode> games = [];
  GameMode item1 = GameMode(
      price: 100, defaultPrice: 50, mode: "Fun", id: 1, gameId: 1, selected: 1);
  GameMode item2 = GameMode(
      price: 100,
      defaultPrice: 50,
      mode: "Rank",
      id: 2,
      gameId: 2,
      selected: 1);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(microseconds: 100), () {
      // if (StorageManager.sharedPreferences.getBool(firsttuto) ?? true) {
      intro.start(context);
      // }
    });
  }

  // @override
  // void dispose() {
  //   Future.delayed(Duration(microseconds: 0), () {
  //     intro.dispose();
  //   });
  //   super.dispose();
  // }

  Card _buildTitleWidget({String title}) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: <Widget>[
            Text(title,
                style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            Divider(thickness: 2),
          ],
        ),
      ),
    );
  }

  Card _buildGameProfileCard(
      {String title,
      Key key,
      String subtitle,
      IconData iconData,
      Function onTap}) {
    return Card(
      key: key,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 8,
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: Theme.of(context).textTheme.bodyText1),
        subtitle: Text(subtitle),
        trailing: Icon(iconData),
      ),
    );
  }

  Widget _buildDivider() {
    return Column(
      children: <Widget>[
        SizedBox(height: 10),
        Divider(thickness: 2, indent: 32, endIndent: 32),
        SizedBox(height: 10)
      ],
    );
  }

  Widget _buildBookingService() {
    return Column(
      children: [
        SizedBox(height: 5),
        _buildTitleWidget(title: G.of(context).gamemodedescript),
        _buildGameProfileCard(
            title: G.of(context).gamemode,
            subtitle: "",
            iconData: Icons.edit,
            onTap: () {}),
      ],
    );
  }

  Card _buildGameProfilePhotoCard() {
    return Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 8,
        child: Column(
          children: [
            Row(
              children: <Widget>[
                ///for now skill cover image later server will give a sample photo url
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Image.asset("assets/images/defaultBackground.jpg",
                      height: 150, width: 180, fit: BoxFit.cover),
                )
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(G.of(context).sample),
                Text(G.of(context).select)
              ],
            ),
            SizedBox(height: 10),
          ],
        ));
  }

  // _onTapGameMode() async {
  //   games.add(item1);
  //   games.add(item2);
  //   print(games);
  //   await Future.delayed(Duration(milliseconds: 2000));
  //   Future.delayed(Duration(microseconds: 100), () {
  //     // if (StorageManager.sharedPreferences.getBool(firsttuto) ?? true) {
  //     intro.start(context);
  //     // }
  //   });
  //   CustomBottomSheet.showGameModeDummyBottomSheet(
  //     buildContext: context,
  //     onDismiss: () {},
  //     games: games,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("LOL"),
        leading: IconButton(
            icon: Icon(CupertinoIcons.back),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: <Widget>[
          CupertinoButton(
            onPressed: () {},
            child: Text("Submit"),
          )
        ],
        bottom: PreferredSize(
            child: Container(
              height: 10,
              color: Theme.of(context).accentColor,
            ),
            preferredSize: Size.fromHeight(10)),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              // color: Colors.grey,
              child: ListView(
                physics: ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
                children: <Widget>[
                  _buildTitleWidget(title: G.of(context).fillgameinfo),
                  _buildGameProfileCard(
                      title: G.of(context).gameid,
                      subtitle: "",
                      iconData: Icons.edit,
                      onTap: () {}),
                  _buildGameProfileCard(
                      title: G.of(context).gamerank,
                      subtitle: '',
                      iconData: Icons.edit,
                      onTap: () {}),
                  _buildDivider(),
                  Card(
                    margin: EdgeInsets.zero,
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    elevation: 8,
                    child: ListTile(
                      title: Text(
                        G.current.alarmRatio,
                      ),
                    ),
                  ),
                  _buildDivider(),
                  _buildBookingService(),
                  _buildDivider(),
                  _buildTitleWidget(title: G.of(context).titlescreenshot),
                  _buildGameProfilePhotoCard(),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(10.0),
                    topRight: const Radius.circular(10.0),
                  ),
                ),
                elevation: 10,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Cancel",
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 18),
                          ),
                          Text(
                            "Select Game Mode",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            "Confirm",
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      ListTile(
                        key: intro.keys[0],
                        title: Text("FUN"),
                        subtitle: Text("100 Coins"),
                        trailing: Icon(Icons.check,
                            color: Theme.of(context).accentColor),
                      ),
                      ListTile(
                        title: Text("Rank"),
                        subtitle: Text("200 Coins"),
                        trailing: Icon(Icons.check,
                            color: Theme.of(context).accentColor),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
