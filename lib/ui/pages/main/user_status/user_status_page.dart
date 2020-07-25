import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/BottomClipper.dart';
import 'package:moonblink/base_widget/indicator/appbar_indicator.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/theme_model.dart';
import 'package:moonblink/view_model/user_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:moonblink/view_model/user_model.dart';

class UserStatusPage extends StatefulWidget {
  @override
  _UserStatusPageState createState() => _UserStatusPageState();
}

class _UserStatusPageState extends State<UserStatusPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
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
                          ScopedModel.of<ChatModel>(context,
                                  rebuildOnChange: false)
                              .disconnect();
                          model.logout().then((value) => value
                              ? Navigator.of(context).pushNamedAndRemoveUntil(
                                  RouteName.main, (route) => false)
                              : null);
                        },
                      );
                    }
                    return SizedBox.shrink();
                  })
            ],
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            expandedHeight: 200 + MediaQuery.of(context).padding.top,
            flexibleSpace: UserHeaderWidget(),
            pinned: false,
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
          ),
          UserListWidget(),
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
          )
        ],
      ),
    );
  }
}

class UserHeaderWidget extends StatelessWidget {
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
                                    ? Image.network(
                                        model.user.profileUrl,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                        // color: Theme.of(context)
                                        //     .accentColor
                                        //     .withAlpha(100),
                                        // colorBlendMode: BlendMode.colorDodge
                                      )
                                    : Image.asset(
                                        ImageHelper.wrapAssetsLogo(
                                            'MoonBlink_Cute.png'),
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                        color: Theme.of(context)
                                            .accentColor
                                            .withAlpha(100),
                                        // https://api.flutter.dev/flutter/dart-ui/BlendMode-class.html
                                        colorBlendMode: BlendMode.colorDodge),
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

class UserListWidget extends StatelessWidget {
  // var statusModel = Provider.of < (context);
  var hasUser = StorageManager.localStorage.getItem(mUser);
  @override
  Widget build(BuildContext context) {
    // var iconColor = Theme.of(context).accentColor;
    // int usertype = StorageManager.sharedPreferences.getInt(mUserType);
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        mainAxisSpacing: 15.0,
      ),
      delegate: SliverChildListDelegate.fixed([
        ///wallet
        PageCard(
            pageTitle: S.of(context).userStatusWallet,
            iconData: FontAwesomeIcons.wallet,
            onTap: hasUser == null
                ? () {
                    showToast('Login First');
                  }
                : () {
                    Navigator.of(context).pushNamed(RouteName.wallet);
                  }),

        ///favorites
        PageCard(
            pageTitle: S.of(context).userStatusFavorite,
            iconData: FontAwesomeIcons.solidHeart,
            onTap: hasUser == null
                ? () {
                    showToast('Login First');
                  }
                : () {
                    Navigator.of(context).pushNamed(RouteName.network);
                  }),

        ///switch dark mode
        PageCard(
            pageTitle: S.of(context).userStatusDarkMode,
            iconData: Theme.of(context).brightness == Brightness.light
                ? FontAwesomeIcons.sun
                : FontAwesomeIcons.moon,
            onTap: () => _switchDarkMode(context)),

        ///theme
        PageCard(
            pageTitle: S.of(context).userStatusTheme,
            iconData: FontAwesomeIcons.palette,
            onTap: () => _showPaletteDialog(context)),

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
            onTap: null),
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
            Text(pageTitle,
                style:
                    TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                softWrap: true)
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

/*ListTileTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: SliverList(
        delegate: SliverChildListDelegate([
          /// wallet
          ListTile(
            leading: Icon(
              FontAwesomeIcons.wallet,
              color: iconColor,
            ),
            title: Text(S.of(context).userStatusWallet),
            onTap: () {
              Navigator.of(context).pushNamed(RouteName.wallet);
            },
            trailing: Icon(Icons.chevron_right),
          ),

          /// for chat their favorites
          ListTile(
            title: Text(S.of(context).userStatusFavorite),
            onTap: () {
              Navigator.of(context).pushNamed(RouteName.network);
            },
            leading: Icon(
              FontAwesomeIcons.solidHeart,
              color: iconColor,
            ),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            title: Text(S.of(context).userStatusDarkMode),
            onTap: () {
              switchDarkMode(context);
            },
            leading: Transform.rotate(
              angle: -pi,
              child: Icon(
                Theme.of(context).brightness == Brightness.light
                    ? FontAwesomeIcons.sun
                    : FontAwesomeIcons.moon,
                color: iconColor,
              ),
            ),
            trailing: CupertinoSwitch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  switchDarkMode(context);
                }),
          ),
          SettingThemeWidget(),

          ListTile(
            title: Text(S.of(context).userStatusSettings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SettingsPage();
                  },
                ),
              );
            },
            leading: Icon(
              FontAwesomeIcons.cog,
              color: iconColor,
            ),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            title: Text(S.of(context).userStatusCheckAppUpdate),
            onTap: () {
              // Navigator.push(
              //   context,
              //   CupertinoPageRoute(
              //     builder: (context) => ChangeLogPage(),
              //     fullscreenDialog: true,
              //   ),
              // );
            },
            leading: Icon(
              FontAwesomeIcons.android,
              color: iconColor,
            ),
            trailing: Icon(Icons.chevron_right),
          ),
          SizedBox(
            height: 30,
          )
        ]),
      ),
    );*/
