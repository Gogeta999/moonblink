import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/encrypt.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/ui/helper/openfacebook.dart';
import 'package:moonblink/ui/helper/openstore.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/theme_model.dart';
import 'package:moonblink/view_model/user_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

class NewUserStatusPage extends StatefulWidget {
  @override
  _NewUserStatusPageState createState() => _NewUserStatusPageState();
}

class _NewUserStatusPageState extends State<NewUserStatusPage> {

  @override
  void initState() {
    // PushNotificationsManager().showgameprofilenoti();
    print('token: ${StorageManager.sharedPreferences.getString(token)}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // int usertype = StorageManager.sharedPreferences.getInt(mUserType);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            ///[Appbar]
            backgroundColor: Colors.black,
            pinned: true,
            // toolbarHeight: kToolbarHeight - 5,
            // expandedHeight: kToolbarHeight,
            // brightness: Theme.of(context).brightness == Brightness.light
            //     ? Brightness.light
            //     : Brightness.dark,
            leading: AppbarLogo(),
            actions: <Widget>[
              InkResponse(
                onTap: /*hasUser == null
                    ? () {
                  showToast(G.of(context).loginFirst);
                }
                    : */openFacebookPage,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SvgPicture.asset(
                    customerservice,
                    color: Colors.red,
                    height: 50,
                    width: 50,
                    semanticsLabel: G.of(context).userStatusCustomerService,
                  ),
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
          UserListWidget(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 20,
            ),
          )
        ],
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
        return Material(
            elevation: 8,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListTile(
                leading: Icon(
                  FontAwesomeIcons.signOutAlt,
                  color: Colors.black,
                ),
                title: Text(G.of(context).logout,
                    style: Theme.of(context).textTheme.bodyText1),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  model.logout();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(RouteName.login, (route) => false);
                },
              ),
            ));
      },
    );
  }
}

class UserListWidget extends StatefulWidget {
  // var statusModel = Provider.of < (context);

  @override
  _UserListWidgetState createState() => _UserListWidgetState();
}

class _UserListWidgetState extends State<UserListWidget> {
  final hasUser = StorageManager.localStorage.getItem(mUser);

  int usertype = StorageManager.sharedPreferences.getInt(mUserType);

  int userid = StorageManager.sharedPreferences.getInt(mUserId);

  var userProfile = StorageManager.sharedPreferences.getString(mUserProfile);

  Wallet userWallet;

  Widget blankSpace() => SizedBox(height: 10);

  @override
  void initState() {
    if (StorageManager.sharedPreferences.getString(token) != null) init();
    super.initState();
  }

  init() async {
    Wallet wallet = await MoonBlinkRepository.getUserWallet();
    setState(() {
      this.userWallet = wallet;
    });
  }

  @override
  Widget build(BuildContext context) {
    int status = StorageManager.sharedPreferences.getInt(mstatus);
    print("user type is ${usertype.toString()}");
    print("user status is ${status.toString()}");

    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        ///Profile update and customer service
        Consumer<UserModel>(builder: (context, model, child) {
          return Material(
              elevation: 8,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
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
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
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
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(model.user.name,
                                style: Theme.of(context).textTheme.bodyText1),
                            SizedBox(width: 20),
                            Icon(
                              FontAwesomeIcons.coins,
                              color: Colors.amber[500],
                              size: 20,
                            ),
                            SizedBox(width: 5.0),
                            userWallet != null ? Text(
                                '${userWallet.value} ${userWallet.value > 1 ? 'coins' : 'coin'}',
                                style: TextStyle(fontSize: 16)) : CupertinoActivityIndicator()
                          ],
                        ),
                        SizedBox(height: 5),
                        InkResponse(
                          onTap: () {
                            String id = encrypt(userid);
                            FlutterClipboard.copy(id).then((value) {
                              showToast(G.of(context).toastcopy);
                              print('copied');
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.content_copy,
                                size: 18,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              Text("copy ID"),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  //trailing: Icon(Icons.chevron_right),
                ),
              ));
        }),

        blankSpace(),

        /// Online/ Offline
        if (usertype != 0)
          Material(
            elevation: 8,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListTile(
                  leading: SvgPicture.asset(
                    status != 1 ? online : offline,
                    color: Colors.redAccent,
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                  title: Text(
                      status != 1 ? G.of(context).online : G.of(context).offline,
                      style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.chevron_right),
                  onTap: status != 1
                      ? () {
                          setState(() {
                            StorageManager.sharedPreferences.setInt(mstatus, 1);
                          });
                          print(status);
                          print("+++++++++++++++++++++++++++");
                          MoonBlinkRepository.changestatus(1);
                          showToast(G.of(context).toastoffline);
                        }
                      : () {
                          setState(() {
                            StorageManager.sharedPreferences.setInt(mstatus, 0);
                            // status = 0;
                          });
                          print(status);
                          print("----------------------------");
                          MoonBlinkRepository.changestatus(0);
                          showToast(G.of(context).toastonline);
                        }),
            ),
          ),
        if (usertype != 0)
        //blankSpace(),

        ///Game Profile
        if (usertype != 0)
          Material(
            elevation: 8,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListTile(
                  leading: SvgPicture.asset(
                    gameProfile,
                    color: Colors.blueGrey,
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                  title: Text(G.of(context).profilegame,
                      style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context)
                      .pushNamed(RouteName.chooseUserPlayGames)),
            ),
          ),
        if (usertype != 0)
        //blankSpace(),

        ///OwnProfile
        if (usertype != 0)
          Material(
            elevation: 8,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListTile(
                  leading: SvgPicture.asset(
                    profileEdit,
                    color: Colors.deepOrange,
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                  title: Text(G.of(context).profileown,
                      style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context)
                      .pushNamed(RouteName.partnerOwnProfile)),
            ),
          ),
        if (usertype != 0)
        //blankSpace(),

        ///Wallet
        Material(
          elevation: 8,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListTile(
                leading: SvgPicture.asset(
                  wallet,
                  color: Colors.greenAccent,
                  height: 50,
                  width: 50,
                  fit: BoxFit.contain,
                ),
                title: Text(G.of(context).userStatusWallet,
                    style: Theme.of(context).textTheme.bodyText1),
                trailing: Icon(Icons.chevron_right),
                onTap: hasUser == null
                    ? () {
                        showToast(G.of(context).loginFirst);
                      }
                    : () {
                        Navigator.of(context).pushNamed(RouteName.wallet);
                      }),
          ),
        ),

        //blankSpace(),

        /// Switch dark mode
        Material(
          elevation: 8,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListTile(
                leading: Icon(
                  Theme.of(context).brightness == Brightness.light
                      ? FontAwesomeIcons.sun
                      : FontAwesomeIcons.moon,
                  size: 30,
                  color: Colors.purpleAccent,
                ),
                title: Text(
                    Theme.of(context).brightness == Brightness.light
                        ? G.of(context).userStatusDayMode
                        : G.of(context).userStatusDarkMode,
                    style: Theme.of(context).textTheme.bodyText1),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _switchDarkMode(context)),
          ),
        ),

        //blankSpace(),

        ///Theme
        Material(
          elevation: 8,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListTile(
                leading: SvgPicture.asset(
                  theme,
                  color: Colors.pinkAccent,
                  height: 50,
                  width: 50,
                  fit: BoxFit.contain,
                ),
                title: Text(G.of(context).userStatusTheme,
                    style: Theme.of(context).textTheme.bodyText1),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _showPaletteDialog(context)),
          ),
        ),

        //blankSpace(),

        ///Settings
        Material(
          elevation: 8,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListTile(
                leading: SvgPicture.asset(
                  setting,
                  color: Colors.grey,
                  height: 50,
                  width: 50,
                  fit: BoxFit.contain,
                ),
                title: Text(G.of(context).userStatusSettings,
                    style: Theme.of(context).textTheme.bodyText1),
                trailing: Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed(RouteName.setting)),
          ),
        ),

        //blankSpace(),

        ///check app update
        Material(
          elevation: 8,
          // shadowColor: Theme.of(context).brightness == Brightness.light
          //     ? Colors.black26
          //     : Colors.white12,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListTile(
                leading: Icon(
                  Platform.isAndroid
                      ? FontAwesomeIcons.android
                      : FontAwesomeIcons.appStoreIos,
                  size: 30,
                  color: Colors.blue,
                ),
                title: Text(G.of(context).userStatusCheckAppUpdate,
                    style: Theme.of(context).textTheme.bodyText1),
                trailing: Icon(Icons.chevron_right),
                onTap: () => openStore()),
          ),
        ),

        //blankSpace(),

        ///Logout
        if (StorageManager.sharedPreferences.getString(token) != null) Logout(),
      ]),
    );
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
