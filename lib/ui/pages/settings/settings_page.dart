import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/container/titleContainer.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/ownprofile.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/ui/helper/openstore.dart';
import 'package:moonblink/view_model/partner_ownProfile_model.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isSigning = false;
  OwnProfile partnerData;
  @override
  void initState() {
    super.initState();
  }

  // Widget typestatus(int status) {
  //   switch (status) {
  //     case (-1):
  //       return Icon(Icons.chevron_right);
  //     case (0):
  //       return Text(
  //         "Pending",
  //         style: TextStyle(color: Theme.of(context).accentColor),
  //       );
  //   }
  // }

  space() {
    return SizedBox(
      height: 30,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              leading: IconButton(
                icon: SvgPicture.asset(
                  back,
                  semanticsLabel: 'back',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).accentColor
                      : Colors.white,
                  width: 30,
                  height: 30,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: PreferredSize(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).accentColor,
                        // spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 0), // changes position of shadow
                      ),
                    ],
                  ),
                  height: 5,
                ),
                preferredSize: Size.fromHeight(8),
              ),
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
                          color: Theme.of(context).scaffoldBackgroundColor,
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
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Center(
                            child: Text(
                          G.of(context).settingsSettings,
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
                          child: Text(G.of(context).termAndConditions),
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
                      child: Text(G.of(context).licenseagreement),
                    ),
                  ),
                ),
                space(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: ShadedContainer(
                    height: 50,
                    ontap: () => openStore(),
                    child: Center(
                      child: Text(G.of(context).ratingApp),
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
                      child: Text(G.of(context).block),
                    ),
                  ),
                ),
                if (usertype == 0) space(),
                if (usertype == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: ShadedContainer(
                      height: 50,
                      ontap: () => Navigator.pushNamed(context, RouteName.otp),
                      child: Center(
                        child: Text(G.of(context).settingsSignAsPartner),
                      ),
                    ),
                  ),
                if (usermodel.partnerData.typestatus == -1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: ShadedContainer(
                      height: 50,
                      ontap: () => showToast("Pending to be partner"),
                      child: Center(
                        child: Text(
                          "Pending to be Partner",
                          style: TextStyle(color: Colors.blue),
                        ),
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
                      child: Text(G.of(context).settingLanguage),
                    ),
                  ),
                ),
                space(),
              ],
            ),
          );
        });
  }
}
