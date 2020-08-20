import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/BottomClipper.dart';
import 'package:moonblink/base_widget/indicator/appbar_indicator.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/theme_model.dart';
import 'package:moonblink/view_model/user_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UserStatusPage extends StatefulWidget {
  @override
  _UserStatusPageState createState() => _UserStatusPageState();
}

class _UserStatusPageState extends State<UserStatusPage> {
  Wallet wallet = Wallet(value: 0);
  bool hasUser = false;

  @override
  void initState() {
    if (StorageManager.sharedPreferences.getString(token) != null) init();
    print('token: ${StorageManager.sharedPreferences.getString(token)}');
    super.initState();
  }

  init() async {
    Wallet wallet = await MoonBlinkRepository.getUserWallet();
    setState(() {
      this.wallet = wallet;
      hasUser = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    int usertype = StorageManager.sharedPreferences.getInt(mUserType);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            leading: ProviderWidget<LoginModel>(
                model: LoginModel(Provider.of(context)),
                builder: (context, model, child) {
                  if (model.isBusy) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: AppBarIndicator(),
                    );
                  }
                  if (model.userModel.hasUser && usertype == 1) {
                    return IconButton(
                      tooltip: 'Set Partner Profile',
                      icon: Icon(IconFonts.setProfileIcon),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(RouteName.partnerOwnProfile);
                      },
                    );
                  }
                  return SizedBox.shrink();
                }),
            actions: <Widget>[
              ProviderWidget<LoginModel>(
                  model: LoginModel(Provider.of(context)),
                  builder: (context, model, child) {
                    if (model.isBusy) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: AppBarIndicator(),
                      );
                    }
                    if (model.userModel.hasUser) {
                      return IconButton(
                        tooltip: S.of(context).logout,
                        icon: Icon(FontAwesomeIcons.signOutAlt),
                        onPressed: () {
                          model.logout();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              RouteName.login, (route) => false);
                        },
                      );
                    }
                    return SizedBox.shrink();
                  })
            ],
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            expandedHeight: 200 + MediaQuery.of(context).padding.top,
            flexibleSpace: UserHeaderWidget(),
            pinned: true,
          ),
          if (hasUser)
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.coins,
                    color: Colors.amber[500],
                    size: 20,
                  ),
                  SizedBox(width: 5.0),
                  Text(
                      '${S.of(context).currentcoin} : ${wallet.value} ${wallet.value > 1 ? 'coins' : 'coin'}',
                      style: TextStyle(fontSize: 16))
                ],
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.only(top: 10),
          ),
          UserListWidget(),
        ],
      ),
    );
  }
}

class UserHeaderWidget extends StatefulWidget {
  @override
  _UserHeaderWidgetState createState() => _UserHeaderWidgetState();
}

class _UserHeaderWidgetState extends State<UserHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
        // in widget
        clipper: BottomClipper(),
        child: Container(
            color: Theme.of(context).primaryColor.withAlpha(200),
            padding: EdgeInsets.only(top: 10),
            child: Consumer<UserModel>(
                builder: (context, model, child) => InkWell(
                    onTap: model.hasUser
                        ? null
                        : () {
                            Navigator.of(context).pushNamed(RouteName.login);
                          },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              int usertype = StorageManager.sharedPreferences
                                  .getInt(mUserType);
                              if (usertype == 1) {
                                Navigator.of(context)
                                    .pushNamed(RouteName.partnerOwnProfile);
                              } else if (model?.user?.token == null) {
                                Navigator.of(context)
                                    .pushNamed(RouteName.login);
                              }
                            },
                            child: Hero(
                              tag: 'loginLogo',
                              child: ClipOval(
                                child: model.hasUser
                                    ? CachedNetworkImage(
                                        imageUrl: model.user.profileUrl,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      )
                                    : Image.asset(
                                        ImageHelper.wrapAssetsImage(
                                            'MoonBlinkProfile.jpg'),
                                        fit: BoxFit.fill,
                                        width: 120,
                                        height: 120,
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          //Show user name here
                          Column(children: <Widget>[
                            Text(
                                model.hasUser
                                    ? model.user.name.toString()
                                    : S.of(context).toSignIn,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .apply(color: Colors.white.withAlpha(200))),
                            SizedBox(
                              height: 10,
                            ),
                            // if (model.hasUser) UserCoin()
                          ])
                        ])))));
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

  @override
  Widget build(BuildContext context) {
    int status = StorageManager.sharedPreferences.getInt(mstatus);
    print("user type is ${usertype.toString()}");
    print("user status is ${status.toString()}");

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        mainAxisSpacing: 15.0,
      ),
      delegate: SliverChildListDelegate.fixed([
        if (usertype == 1)
          PageCard(
              pageTitle:
                  status != 1 ? S.of(context).online : S.of(context).offline,
              iconData:
                  status != 1 ? FontAwesomeIcons.wifi : Icons.portable_wifi_off,
              onTap: status != 1
                  ? () {
                      setState(() {
                        StorageManager.sharedPreferences.setInt(mstatus, 1);
                      });
                      print(status);
                      print("+++++++++++++++++++++++++++");
                      MoonBlinkRepository.changestatus(1);
                      showToast(S.of(context).toastoffline);
                    }
                  : () {
                      setState(() {
                        StorageManager.sharedPreferences.setInt(mstatus, 0);
                        // status = 0;
                      });
                      print(status);
                      print("----------------------------");
                      MoonBlinkRepository.changestatus(0);
                      showToast(S.of(context).toastonline);
                    }),

        ///wallet
        PageCard(
            pageTitle: S.of(context).userStatusWallet,
            iconData: FontAwesomeIcons.wallet,
            onTap: hasUser == null
                ? () {
                    showToast(S.of(context).loginFirst);
                  }
                : () {
                    Navigator.of(context).pushNamed(RouteName.wallet);
                  }),

        ///switch dark mode
        PageCard(
            pageTitle: Theme.of(context).brightness == Brightness.light
                ? S.of(context).userStatusDayMode
                : S.of(context).userStatusDarkMode,
            iconData: Theme.of(context).brightness == Brightness.light
                // ? IconFonts.dayModeIcon
                ? IconFonts.dayModeIcon
                : FontAwesomeIcons.moon,
            onTap: () => _switchDarkMode(context)),

        ///theme
        PageCard(
            pageTitle: S.of(context).userStatusTheme,
            iconData: FontAwesomeIcons.palette,
            onTap: () => _showPaletteDialog(context)),

        ///favorites
        PageCard(
            pageTitle: S.of(context).userStatusCustomerService,
            iconData: FontAwesomeIcons.handsHelping,
            onTap: hasUser == null
                ? () {
                    showToast(S.of(context).loginFirst);
                  }
                // : () {
                //     Navigator.of(context).pushNamed(RouteName.network);
                //   }),
                : _openFacebookPage),

        ///settings
        PageCard(
            pageTitle: S.of(context).userStatusSettings,
            iconData: FontAwesomeIcons.cog,
            onTap: () => Navigator.of(context).pushNamed(RouteName.setting)),

        ///check app update
        PageCard(
            pageTitle: S.of(context).userStatusCheckAppUpdate,
            iconData: Platform.isAndroid
                ? FontAwesomeIcons.android
                : FontAwesomeIcons.appStoreIos,
            onTap: _openStore),
      ]),
    );
  }

  void _openStore() async {
    String appStoreUrl;
    if (Platform.isIOS) {
      appStoreUrl = 'fb://profile/103254564508101';
    } else {
      appStoreUrl =
          'https://play.google.com/store/apps/details?id=com.moonuniverse.moonblink';
    }
    const String pageUrl = 'https://www.facebook.com/Moonblink2000';
    try {
      bool nativeAppLaunch = await launch(appStoreUrl,
          forceSafariVC: false, universalLinksOnly: true);
      if (!nativeAppLaunch) {
        await launch(pageUrl, forceSafariVC: false);
      }
    } catch (e) {
      await launch(pageUrl, forceSafariVC: false);
    }
  }

  void _openFacebookPage() async {
    String fbProtocolUrl;
    if (Platform.isIOS) {
      fbProtocolUrl = 'fb://profile/103254564508101';
    } else {
      fbProtocolUrl = 'fb://page/103254564508101';
    }
    const String pageUrl = 'https://www.facebook.com/Moonblink2000';
    try {
      bool nativeAppLaunch = await launch(fbProtocolUrl,
          forceSafariVC: false, universalLinksOnly: true);
      if (!nativeAppLaunch) {
        await launch(pageUrl, forceSafariVC: false);
      }
    } catch (e) {
      await launch(pageUrl, forceSafariVC: false);
    }
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

class PageCard extends StatelessWidget {
  final String pageTitle;
  final IconData iconData;
  final Function onTap;

  const PageCard(
      {Key key,
      @required this.pageTitle,
      @required this.iconData,
      @required this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Card(
        elevation: 0.0,
        color: Theme.of(context).primaryColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Icon(
              iconData,
              color: Colors.white,
              size: 26.0,
            ),
            Center(
              child: Text(pageTitle,
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.white),
                  softWrap: true),
            )
          ],
        ),
      ),
    );
  }
}

class SettingThemeWidget extends StatelessWidget {
  SettingThemeWidget();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(S.of(context).userStatusTheme),
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
