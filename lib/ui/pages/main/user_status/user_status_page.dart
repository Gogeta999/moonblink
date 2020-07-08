import 'dart:math';

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
import 'package:moonblink/ui/pages/settings/settings_page.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/theme_model.dart';
import 'package:moonblink/view_model/user_model.dart';
import 'package:provider/provider.dart';

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
                          model.logout().then((value) => value
                              ? Navigator.of(context).pushNamedAndRemoveUntil(
                                  RouteName.splash, (route) => false)
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
          UserListWidget(),
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
                              } else if (model.user == null) {
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
                                        width: 130,
                                        height: 130,
                                        // color: Theme.of(context)
                                        //     .accentColor
                                        //     .withAlpha(100),
                                        // colorBlendMode: BlendMode.colorDodge
                                      )
                                    : Image.asset(
                                        ImageHelper.wrapAssetsLogo(
                                            'MoonBlink_logo.png'),
                                        fit: BoxFit.cover,
                                        width: 130,
                                        height: 130,
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
  @override
  Widget build(BuildContext context) {
    var iconColor = Theme.of(context).accentColor;
    // int usertype = StorageManager.sharedPreferences.getInt(mUserType);
    return ListTileTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: SliverList(
        delegate: SliverChildListDelegate([
          /// for normal user to signup as partner
          // if (usertype != 1)
          //   ListTile(
          //     title: Text('Register as our partner'),
          //     onTap: () async {
          //       CupertinoActivityIndicator();
          //       var userid = StorageManager.sharedPreferences.getInt(mUserId);
          //       var usertoken =
          //           StorageManager.sharedPreferences.getString(token);
          //       var response = await DioUtils().post(
          //           Api.RegisterAsPartner + '$userid/register',
          //           queryParameters: {
          //             'Authorization': 'Bearer' + usertoken.toString()
          //           });
          //       print(response);
          //       Navigator.of(context).pushNamed(RouteName.registerAsPartner);
          //     },
          //     leading: Icon(
          //       FontAwesomeIcons.user,
          //       color: iconColor,
          //     ),
          //     trailing: Icon(Icons.chevron_right),
          //   ),

          /// wallet
          ListTile(
            leading: Icon(
              FontAwesomeIcons.wallet,
              color: iconColor,
            ),
            title: Text('Wallet'),
            onTap: () {
              Navigator.of(context).pushNamed(RouteName.wallet);
            },
            trailing: Icon(Icons.chevron_right),
          ),

          /// for chat their favorites
          ListTile(
            title: Text(S.of(context).favorites),
            onTap: () {
              Navigator.of(context).pushNamed(RouteName.setprofile);
            },
            leading: Icon(
              FontAwesomeIcons.solidHeart,
              color: iconColor,
            ),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            title: Text(S.of(context).darkMode),
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
            title: Text(S.of(context).settings),
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
            title: Text(S.of(context).appUpdateCheck),
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
    );
  }

  void switchDarkMode(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
    } else {
      Provider.of<ThemeModel>(context, listen: false).switchTheme(
          userDarkMode: Theme.of(context).brightness == Brightness.light);
    }
  }
}

class SettingThemeWidget extends StatelessWidget {
  SettingThemeWidget();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(S.of(context).theme),
      leading: Icon(
        FontAwesomeIcons.palette,
        color: Theme.of(context).accentColor,
      ),
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
