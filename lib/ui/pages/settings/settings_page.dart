import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/local_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: Text(G.of(context).settingsSettings),
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
                        : Text(G.of(context).settingsSignAsPartner),
                    onTap: () async {
                      var usertoken =
                          StorageManager.sharedPreferences.getString(token);
                      if (usertoken != null) {
                        setState(() {
                          isSigning = !isSigning;
                        });
                        Navigator.of(context).pushNamed(RouteName.otp);
                        setState(() {
                          isSigning = !isSigning;
                        });
                      } else {
                        showToast(G.of(context).showToastSignInFirst);
                      }
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
                      Text(G.of(context).settingLanguage
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
                  title: Text(G.of(context).termAndConditions),
                  onTap: () async {
                    Navigator.of(context)
                        .pushNamed(RouteName.termsAndConditionsPage);
                  },
                  leading: Icon(Icons.book, color: iconColor),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Material(
                color: Theme.of(context).cardColor,
                child: ListTile(
                  title: Text(G.of(context).licenseagreement),
                  onTap: () async {
                    Navigator.of(context).pushNamed(RouteName.licenseAgreement);
                  },
                  leading: Icon(Icons.book, color: iconColor),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Material(
                color: Theme.of(context).cardColor,
                child: ListTile(
                  title: Text(G.of(context).ratingApp),
                  onTap: _openStore,
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
                  title: Text(G.of(context).feedback),
                  onTap: _openFacebookPage,
                  leading: Icon(
                    Icons.feedback,
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
                child: ListTile(
                  title: Text(G.of(context).blockList),
                  onTap: () {
                    Navigator.pushNamed(context, RouteName.blockedUsers);
                  },
                  leading: Icon(
                    Icons.block,
                    color: iconColor,
                  ),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            ],
          ),
        ),
      ),
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
}
