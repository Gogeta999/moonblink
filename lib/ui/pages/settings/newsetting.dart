import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/container/titleContainer.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/helper/openstore.dart';
import 'package:moonblink/view_model/partner_ownProfile_model.dart';
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
                    ontap: () => openStore(),
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
                if (usertype == 0) space(),
                // if (usertype == 0)
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
}
