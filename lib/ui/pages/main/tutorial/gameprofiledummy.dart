import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/intro/flutter_intro.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/ui/helper/tutorial.dart';
import 'package:moonblink/ui/pages/main/tutorial/gamepricedummy.dart';
import 'package:moonblink/ui/pages/main/tutorial/homepagedummy.dart';

class GameProfileDummy extends StatefulWidget {
  GameProfileDummy({Key key}) : super(key: key);

  @override
  _GameProfileDummyState createState() => _GameProfileDummyState();
}

class _GameProfileDummyState extends State<GameProfileDummy> {
  Intro intro;

  _GameProfileDummyState() {
    intro = Intro(
      stepCount: 3,
      borderRadius: BorderRadius.circular(15),
      onfinish: () {
        intro.dispose();
        Future.delayed(
          Duration(microseconds: 0),
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GamePriceDummy(),
              ),
            );
          },
        );
      },

      /// use defaultTheme, or you can implement widgetBuilder function yourself
      widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        texts: [
          G.of(context).tutogameprofile1,
          G.of(context).tutogameprofile2,
          G.of(context).tutogameprofile3,
        ],
        buttonTextBuilder: (curr, total) {
          return curr < total - 1 ? G.of(context).next : G.of(context).finish;
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(microseconds: 0), () {
      if (StorageManager.sharedPreferences.getBool(firsttuto) ?? true) {
        intro.start(context);
      }
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
            key: intro.keys[2],
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
                InkResponse(onTap: () {}, child: Text(G.of(context).select))
              ],
            ),
            SizedBox(height: 10),
          ],
        ));
  }

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
          child: ListView(
            physics: ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
            children: <Widget>[
              _buildTitleWidget(title: G.of(context).fillgameinfo),
              _buildGameProfileCard(
                  key: intro.keys[0],
                  title: G.of(context).gameid,
                  subtitle: "",
                  iconData: Icons.edit,
                  onTap: () {}),
              _buildGameProfileCard(
                  key: intro.keys[1],
                  title: G.of(context).gamerank,
                  subtitle: '',
                  iconData: Icons.edit,
                  onTap: () {}),
              _buildDivider(),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 8,
                child: ListTile(
                  onTap: null,
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
        ));
  }
}
