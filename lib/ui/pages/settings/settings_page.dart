import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/ui/pages/new_user_swiper_page.dart';
import 'package:moonblink/view_model/local_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:moonblink/view_model/login_model.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isSigning = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var iconColor = Theme.of(context).accentColor;
    int usertype = StorageManager.sharedPreferences.getInt(mUserType);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settingsSettings),
      ),
      body: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: <Widget>[
              if (usertype != 1)
                Material(
                  color: Theme.of(context).cardColor,
                  child: ListTile(
                    title: isSigning
                        ? CupertinoActivityIndicator()
                        : Text(S.of(context).settingsSignAsPartner),
                    onTap: () async {
                      var userid =
                          StorageManager.sharedPreferences.getInt(mUserId);
                      var usertoken =
                          StorageManager.sharedPreferences.getString(token);
                      if (usertoken != null) {
                        setState(() {
                          isSigning = !isSigning;
                        });
                        var response = await DioUtils().post(
                            Api.RegisterAsPartner + '$userid/register',
                            queryParameters: {
                              'Authorization': 'Bearer' + usertoken.toString()
                            });
                        print(response);
                        Navigator.of(context)
                            .pushNamed(RouteName.registerAsPartner);
                        setState(() {
                          isSigning = !isSigning;
                        });
                      } else {
                        showToast(S.of(context).showToastSignInFirst);
                      }

                      // if (response.errorcode == 1) {
                      //   setState(() {
                      //     isSigning = !isSigning;
                      //   });
                      // }
                    },
                    leading: Icon(
                      FontAwesomeIcons.user,
                      color: iconColor,
                    ),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ),
              SizedBox(
                height: 20,
              ),
              Material(
                color: Theme.of(context).cardColor,
                child: ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(S.of(context).settingLanguage
                          // style: TextStyle(),
                          ),
                      Text(LocaleModel.localeName(
                          Provider.of<LocaleModel>(context).localeIndex,
                          context)),
                    ],
                  ),
                  leading: Icon(
                    Icons.public,
                    color: iconColor,
                  ),
                  children: <Widget>[
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: LocaleModel.localeValueList.length,
                        itemBuilder: (context, index) {
                          var model = Provider.of<LocaleModel>(context);
                          return RadioListTile(
                            value: index,
                            groupValue: model.localeIndex,
                            onChanged: (index) {
                              model.switchLocale(index);
                            },
                            title: Text(LocaleModel.localeName(index, context)),
                          );
                        }),
                  ],
                ),
              ),
              //
              SizedBox(
                height: 20,
              ),
              Material(
                color: Theme.of(context).cardColor,
                child: ListTile(
                  title: Text(S.of(context).ratingApp),
                  onTap: () async {
                    print(Text(
                        'Will launch To review after registering at play and ios store'));
                    //   LaunchReview.launch(
                    //       androidAppId: "",
                    //       iOSAppId: "");
                    // },
                  },
                  leading: Icon(Icons.tag_faces, color: iconColor),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Material(
                color: Theme.of(context).cardColor,
                child: ListTile(
                  title: Text(S.of(context).feedback),
                  onTap: () async {
                    print('');
                  },
                  leading: Icon(
                    Icons.feedback,
                    color: iconColor,
                  ),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
              ///newUser on/off Test
              SizedBox(
                height: 20,
              ),
              TestNewUser(iconColor: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}

class TestNewUser extends StatefulWidget {
  final Color iconColor;

  const TestNewUser({Key key, this.iconColor}) : super(key: key);
  @override
  _TestNewUserState createState() => _TestNewUserState();
}

class _TestNewUserState extends State<TestNewUser> {
  bool newUser = StorageManager.sharedPreferences.getBool(isNewUser) ?? true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: ListTile(
        title: Text('isNewUser'),
        leading: Icon(
          Icons.supervisor_account,
          color: widget.iconColor,
        ),
        trailing: CupertinoSwitch(
          value: newUser,
          onChanged: (value) {
            StorageManager.sharedPreferences.setBool(isNewUser, value);
            setState(() {
              newUser = value;
            });
            print('newUser: $newUser');
            print('isNewUser: ${StorageManager.sharedPreferences.getBool(isNewUser)}');
          },
        ),
      ),
    );
  }
}
