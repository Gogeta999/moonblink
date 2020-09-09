import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/roundedContainer.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/container/titleContainer.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/local_model.dart';
import 'package:moonblink/view_model/partner_ownProfile_model.dart';
import 'package:moonblink/view_model/user_model.dart';
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
  PartnerUser partnerData;
  @override
  void initState() {
    super.initState();
  }

  Widget typestatus(int status) {
    switch (status) {
      case (-1):
        return Icon(Icons.chevron_right);
      case (0):
        return Text(
          "Pending",
          style: TextStyle(color: Theme.of(context).accentColor),
        );
    }
  }

  space() {
    return SizedBox(
      height: 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    var iconColor = Theme.of(context).accentColor;
    int usertype = StorageManager.sharedPreferences.getInt(mUserType);
    return ProviderWidget<PartnerOwnProfileModel>(
        model: PartnerOwnProfileModel(partnerData),
        onModelReady: (partnerModel) {
          partnerModel.initData();
        },
        builder: (context, usermodel, index) {
          if (usermodel.isBusy) {
            return ViewStateBusyWidget();
          } else if (usermodel.isError && usermodel.isEmpty) {
            return ViewStateErrorWidget(
                error: usermodel.viewStateError, onPressed: usermodel.initData);
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              actions: [
                AppbarLogo(),
              ],
            ),
            body: ListView(
              children: [
                Stack(
                  children: [
                    Container(
                      color: Colors.black,
                      height: 200,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 150),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(50.0)),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                      child: TitleContainer(
                        height: 100,
                        color: Colors.white,
                        child: Center(
                            child: Text(
                          "Setting",
                          style: TextStyle(fontSize: 30),
                        )),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 180, left: 50, right: 50),
                      child: ShadedContainer(
                        height: 50,
                        ontap: () => Navigator.pushNamed(
                            context, RouteName.termsAndConditionsPage),
                        child: Center(
                          child: Text("Terms and Conditions"),
                        ),
                      ),
                    ),
                  ],
                ),
                space(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: ShadedContainer(
                    height: 50,
                    ontap: () => Navigator.pushNamed(
                        context, RouteName.licenseAgreement),
                    child: Center(
                      child: Text("License Agreement"),
                    ),
                  ),
                ),
                space(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: ShadedContainer(
                    height: 50,
                    ontap: () => _openStore(),
                    child: Center(
                      child: Text("Rate Our App"),
                    ),
                  ),
                ),
                space(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: ShadedContainer(
                    height: 50,
                    ontap: () =>
                        Navigator.pushNamed(context, RouteName.blockedUsers),
                    child: Center(
                      child: Text("Block List"),
                    ),
                  ),
                ),
                space(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: ShadedContainer(
                    height: 50,
                    ontap: () => Navigator.pushNamed(context, RouteName.otp),
                    child: Center(
                      child: Text("Register as Partner"),
                    ),
                  ),
                ),
                space(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: ShadedContainer(
                    height: 50,
                    ontap: () =>
                        Navigator.pushNamed(context, RouteName.language),
                    child: Center(
                      child: Text("Language"),
                    ),
                  ),
                ),
                space(),
              ],
            ),
          );
        });
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
