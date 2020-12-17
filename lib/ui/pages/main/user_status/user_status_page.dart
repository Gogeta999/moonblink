import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/ownprofile.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/encrypt.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/ui/helper/openfacebook.dart';
import 'package:moonblink/ui/helper/openstore.dart';
import 'package:moonblink/ui/pages/main/user_status/userlevel.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/theme_model.dart';
import 'package:moonblink/view_model/user_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserStatusPage extends StatefulWidget {
  @override
  _UserStatusPageState createState() => _UserStatusPageState();
}

class _UserStatusPageState extends State<UserStatusPage> {
  RefreshController refreshController = RefreshController();

  final hasUser = StorageManager.localStorage.getItem(mUser);

  int usertype = StorageManager.sharedPreferences.getInt(mUserType);

  int userid = StorageManager.sharedPreferences.getInt(mUserId);

  var userProfile = StorageManager.sharedPreferences.getString(mUserProfile);

  OwnProfile profile;

  Widget blankSpace() => SizedBox(height: 10);

  @override
  void initState() {
    // PushNotificationsManager().showgameprofilenoti();
    if (isDev) print('token: ${StorageManager.sharedPreferences.getString(token)}');
    if (StorageManager.sharedPreferences.getString(token) != null) init();
    super.initState();
  }

  init() async {
    OwnProfile user = await MoonBlinkRepository.fetchOwnProfile();
    setState(() {
      this.profile = user;
    });
  }

  void _switchDarkMode(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
    } else {
      Provider.of<ThemeModel>(context, listen: false).switchTheme(
          userDarkMode: Theme.of(context).brightness == Brightness.light);
    }
  }

  void _showPaletteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(child: SettingThemeWidget());
      },
    );
  }

  //level dialog
  leveldialog(OwnProfile profile) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Okay"),
            ),
          ],
          content: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text("Level ${profile.level}",
                      style: Theme.of(context).textTheme.headline6),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 20,
                  ),
                  child: new LinearPercentIndicator(
                    // width: MediaQuery.of(context).size.width - 40,
                    animation: true,
                    animationDuration: 1000,
                    lineHeight: 12.0,
                    leading: Text("Exp"),
                    trailing: InkWell(
                      child: Container(
                        padding: EdgeInsets.only(left: 5),
                        width: 10,
                        child: Text("?"),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserLevelPage()));
                      },
                    ),
                    percent: profile != null
                        ? double.parse(profile.levelpercent)
                        : 0,
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    progressColor: Theme.of(context).accentColor,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                    "Need ${profile.leftorder} matches to be level ${(int.parse(profile.level) + 1).toString()}"),
                SizedBox(
                  height: 20,
                ),
                Text("Note: Will expired on ${profile.levelresettime}"),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int status = StorageManager.sharedPreferences.getInt(mstatus);
    String name = StorageManager.sharedPreferences.getString(mLoginName);

    return Scaffold(
      appBar: AppBar(
        ///[Appbar]
        backgroundColor: Colors.black,
        leading: AppbarLogo(),
        actions: <Widget>[
          IconButton(
            onPressed: openCustomerServicePage,
            icon: SvgPicture.asset(
              customerservice,
              height: 30,
              width: 30,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).accentColor
                  : Colors.white,
              semanticsLabel: G.of(context).userStatusCustomerService,
            ),
          ),
        ],
        flexibleSpace: null,
        bottom: PreferredSize(
            child: Container(
              height: 10,
              color: Theme.of(context).accentColor,
            ),
            preferredSize: Size.fromHeight(10)),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[200]
          : null,
      body: SmartRefresher(
        controller: refreshController,
        header: WaterDropHeader(),
        onRefresh: () async {
          setState(() {
            profile = null;
          });
          await init();
          refreshController.refreshCompleted();
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                ///Profile update and customer service
                ProviderWidget<UserModel>(
                  model: UserModel(),
                  builder: (context, model, child) {
                    return Card(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                      elevation: 4,
                      shadowColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.grey,
                      child: ListTile(
                        leading: InkResponse(
                          onTap: () => Navigator.of(context)
                              .pushNamed(RouteName.partnerOwnProfile),
                          child: Hero(
                            tag: 'loginLogo',
                            child: model.hasUser
                                ? CachedNetworkImage(
                                    imageUrl: userProfile,
                                    imageBuilder: (context, item) {
                                      return CircleAvatar(
                                        radius: 28,
                                        backgroundImage: item,
                                      );
                                    },
                                    placeholder: (_, __) =>
                                        CupertinoActivityIndicator(),
                                    errorWidget: (_, __, ___) =>
                                        Icon(Icons.error),
                                  )
                                : CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.black,
                                    child: CircleAvatar(
                                      radius: 70,
                                      backgroundImage: AssetImage(
                                        ImageHelper.wrapAssetsImage(
                                            'MoonBlinkProfile.jpg'),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row(
                              //   children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  if (usertype != 0)
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UserLevelPage()));
                                      },
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          "Lv ${profile != null ? profile.level : "."}",
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 5),
                              InkResponse(
                                onTap: () {
                                  String id = encrypt(userid);
                                  FlutterClipboard.copy(id).then((value) {
                                    showToast(G.of(context).toastcopy);
                                  });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.content_copy,
                                      size: 18,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    Text(G.of(context).copyID),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                //Level Indicator
                if (usertype != 0 &&
                    profile != null &&
                    profile.levelpercent != null &&
                    profile.leftorder != null &&
                    profile.ordercount != null &&
                    profile.level != null)
                  Card(
                    margin: EdgeInsets.only(bottom: 15),
                    elevation: 4,
                    shadowColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.grey,
                    child: InkWell(
                      onTap: () {
                        leveldialog(profile);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Level ${profile != null ? profile.level : "."}",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 15.0,
                                horizontal: 20,
                              ),
                              child: new LinearPercentIndicator(
                                // width: MediaQuery.of(context).size.width - 40,
                                animation: true,
                                animationDuration: 1000,
                                lineHeight: 12.0,
                                leading: Text("Exp"),
                                percent: profile != null
                                    ? double.parse(profile.levelpercent)
                                    : 0,
                                linearStrokeCap: LinearStrokeCap.roundAll,
                                progressColor: Theme.of(context).accentColor,
                              ),
                            ),
                            Text(
                              "${profile != null ? (int.parse(profile.ordercount) - int.parse(profile.leftorder)).toString() : "."} / ${profile != null ? profile.ordercount : "."} ",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Divider(
                //   height: 30,
                // ),

                /// Online/ Offline
                if (usertype != 0)
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                        leading: SvgPicture.asset(
                          status != 1 ? online : offline,
                          // color: Colors.cyan,
                          height: 30,
                          width: 30,
                          fit: BoxFit.contain,
                        ),
                        title: Text(
                            status != 1
                                ? G.of(context).online
                                : G.of(context).offline,
                            style: Theme.of(context).textTheme.bodyText1),
                        // trailing: Icon(Icons.chevron_right),
                        onTap: status != 1
                            ? () {
                                setState(() {
                                  StorageManager.sharedPreferences
                                      .setInt(mstatus, 1);
                                });
                                if (isDev) print(status);
                                if (isDev) print("+++++++++++++++++++++++++++");
                                MoonBlinkRepository.changestatus(1);
                                showToast(G.of(context).toastoffline);
                              }
                            : () {
                                setState(() {
                                  StorageManager.sharedPreferences
                                      .setInt(mstatus, 0);
                                  // status = 0;
                                });
                                if (isDev) print(status);
                                if (isDev) print("----------------------------");
                                MoonBlinkRepository.changestatus(0);
                                showToast(G.of(context).toastonline);
                              }),
                  ),

                ///Game Profile
                if (usertype != 0)
                  Card(
                    margin: EdgeInsets.zero,
                    // elevation: 4,
                    child: ListTile(
                        leading: SvgPicture.asset(
                          gameProfile,
                          // color: Colors.blueGrey,
                          height: 30,
                          width: 30,
                          fit: BoxFit.contain,
                        ),
                        title: Text(G.of(context).profilegame,
                            style: Theme.of(context).textTheme.bodyText1),
                        onTap: () => Navigator.of(context)
                            .pushNamed(RouteName.chooseUserPlayGames)),
                  ),

                ///Boosting Profile
                if (usertype == kPro)
                  Card(
                    margin: EdgeInsets.zero,
                    // elevation: 4,
                    child: ListTile(
                        leading: SvgPicture.asset(
                          boostProfile, //change icon later
                          // color: Colors.blueGrey,
                          height: 30,
                          width: 30,
                          fit: BoxFit.contain,
                        ),
                        trailing: (StorageManager.sharedPreferences
                                .getBool(kNewToBoosting) ?? true)
                            ? Icon(Icons.star_border_outlined)
                            : null,
                        title: Text('Boosting Profile',
                            style: Theme.of(context).textTheme.bodyText1),
                        onTap: () => Navigator.of(context)
                            .pushNamed(RouteName.boostingGameListPage)),
                  ),

                ///OwnProfile
                Card(
                  margin: EdgeInsets.only(bottom: 15),
                  elevation: 4,
                  shadowColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.grey,
                  child: ListTile(
                      leading: SvgPicture.asset(
                        profileEdit,
                        // color: Colors.orangeAccent,
                        height: 32,
                        width: 32,
                        fit: BoxFit.contain,
                      ),
                      title: Text(G.of(context).profileown,
                          style: Theme.of(context).textTheme.bodyText1),
                      onTap: () => Navigator.of(context)
                          .pushNamed(RouteName.partnerOwnProfile)),
                ),
                // blankSpace(),

                ///Wallet
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                      leading: SvgPicture.asset(
                        wallet,
                        // color: Colors.greenAccent,
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                      title: Row(
                        children: [
                          Text(G.of(context).userStatusWallet,
                              style: Theme.of(context).textTheme.bodyText1),
                          SizedBox(width: 20),
                          Icon(
                            FontAwesomeIcons.coins,
                            color: Colors.amber[500],
                            size: 20,
                          ),
                          SizedBox(width: 5.0),
                          profile != null
                              ? Text(
                                  '${profile.wallet.value} ${profile.wallet.value > 1 ? 'coins' : 'coin'}',
                                  style: TextStyle(fontSize: 16))
                              : CupertinoActivityIndicator()
                        ],
                      ),
                      onTap: hasUser == null
                          ? () {
                              showToast(G.of(context).loginFirst);
                            }
                          : () {
                              Navigator.of(context).pushNamed(RouteName.wallet);
                            }),
                ),

                /// Switch dark mode
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                      leading: SvgPicture.asset(
                        Theme.of(context).brightness == Brightness.light
                            ? dayMood
                            : nightMood,
                        width: 30,
                        height: 30,
                        // color: Colors.purpleAccent,
                      ),
                      title: Text(
                          Theme.of(context).brightness == Brightness.light
                              ? G.of(context).userStatusDayMode
                              : G.of(context).userStatusDarkMode,
                          style: Theme.of(context).textTheme.bodyText1),
                      onTap: () => _switchDarkMode(context)),
                ),

                //blankSpace(),

                ///Theme
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                      leading: SvgPicture.asset(
                        theme,
                        // color: Colors.pinkAccent,
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                      title: Text(G.of(context).userStatusTheme,
                          style: Theme.of(context).textTheme.bodyText1),
                      onTap: () => _showPaletteDialog(context)),
                ),

                ///check app update
                Card(
                  margin: EdgeInsets.only(bottom: 15),
                  elevation: 4,
                  shadowColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.grey,
                  child: ListTile(
                      leading: SvgPicture.asset(
                        checkUpdate,
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                      title: Text(G.of(context).userStatusCheckAppUpdate,
                          style: Theme.of(context).textTheme.bodyText1),
                      onTap: () => openStore()),
                ),
                // blankSpace(),

                ///Settings
                Card(
                  margin: EdgeInsets.only(bottom: 10),
                  elevation: 4,
                  shadowColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.grey,
                  child: ListTile(
                      leading: SvgPicture.asset(
                        setting,
                        // color: Colors.black,
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                      title: Text(G.of(context).userStatusSettings,
                          style: Theme.of(context).textTheme.bodyText1),
                      onTap: () =>
                          Navigator.of(context).pushNamed(RouteName.setting)),
                ),
                blankSpace(),

                ///Logout
                if (StorageManager.sharedPreferences.getString(token) != null)
                  Logout(),
              ]),
            ),
            // UserListWidget(profile != null ? profile : null),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 30,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Logout extends StatefulWidget {
  @override
  _LogoutState createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  @override
  Widget build(BuildContext context) {
    return ProviderWidget<LoginModel>(
      model: LoginModel(Provider.of(context)),
      builder: (context, model, child) {
        return Card(
            margin: EdgeInsets.zero,
            shadowColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.grey,
            elevation: 4,
            child: ListTile(
              leading: SvgPicture.asset(
                logout,
                height: 30,
                width: 30,
                fit: BoxFit.contain,
              ),
              title: Text(G.of(context).logout,
                  style: Theme.of(context).textTheme.bodyText1),
              onTap: () {
                model.logout();
                // ScopedModel.of<ChatModel>(context).disconnect();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(RouteName.login, (route) => false);
              },
            ));
      },
    );
  }
}

class SettingThemeWidget extends StatelessWidget {
  SettingThemeWidget();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(G.of(context).userStatusTheme),
      leading: Icon(
        FontAwesomeIcons.palette,
        color: Theme.of(context).accentColor,
      ),
      initiallyExpanded: true,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: <Widget>[
              ...Colors.primaries.map((color) {
                return Material(
                  color: color,
                  child: InkWell(
                    onTap: () {
                      var model =
                          Provider.of<ThemeModel>(context, listen: false);
                      // var brightness = Theme.of(context).brightness;
                      model.switchTheme(color: color);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                    ),
                  ),
                );
              }).toList(),
              Material(
                child: InkWell(
                  onTap: () {
                    var model = Provider.of<ThemeModel>(context, listen: false);
                    var brightness = Theme.of(context).brightness;
                    model.switchRandomTheme(brightness: brightness);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).accentColor)),
                    width: 40,
                    height: 40,
                    child: Text(
                      "?",
                      style: TextStyle(
                          fontSize: 20, color: Theme.of(context).accentColor),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
