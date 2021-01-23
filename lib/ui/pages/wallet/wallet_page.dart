import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/container/titleContainer.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/services/ad_manager.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/ui/pages/wallet/user_transaction_page.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moonblink/ui/helper/openfacebook.dart';

///Emulators are always treated as test devices
const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['game', 'entertainment'],
  contentUrl: 'https://moonblinkunivsere.com',
  nonPersonalizedAds: true,
);

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  Wallet wallet = Wallet(value: 0);

  bool isWalletLoading = false;
  bool isAdLoading = false;

  @override
  void initState() {
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      if (isDev) print("RewardedVideoAd event $event");
      if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {
          userReward();
        });
      }
      if (event == RewardedVideoAdEvent.loaded) {
        RewardedVideoAd.instance.show();
      }
      if (event == RewardedVideoAdEvent.failedToLoad) {
        setState(() {
          isAdLoading = false;
        });
      }
      if (event == RewardedVideoAdEvent.closed) {
        setState(() {
          isAdLoading = false;
        });
      }
      if (event == RewardedVideoAdEvent.leftApplication) {
        setState(() {
          isAdLoading = false;
        });
      }
      if (event == RewardedVideoAdEvent.completed) {
        setState(() {
          isAdLoading = false;
        });
      }
    };

    getUserWallet();
    super.initState();
  }

  // ignore: unused_element
  Widget _buildAds() {
    return isAdLoading
        ? CupertinoActivityIndicator()
        : Text(G.of(context).watchad);
  }

  Widget _buildTopUpWithCustomerService() {
    return Text(G.of(context).userStatusCustomerService);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
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
          SliverToBoxAdapter(
            child: Stack(
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
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                  child: TitleContainer(
                    height: 100,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Center(
                        child: Text(
                      G.of(context).coin,
                      style: TextStyle(fontSize: 30),
                    )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 200),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ShadedContainer(
                            // ontap: () {
                            //   _showTopUpBtmSheet();
                            // },
                            ontap: () => showDialog(
                                context: context,
                                barrierDismissible: false,
                                child: ChoosePayDialog()),
                            child: Text(G.of(context).topup),
                          ),
                          ShadedContainer(
                            ontap: openCustomerServicePage,
                            child: Text(G.of(context).cashout),
                          ),
                          // ShadedContainer(
                          //   ontap: _showRewardedAds,
                          //   child: _buildAds(),
                          // ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ShadedContainer(
                            ontap: _openFacebookPage,
                            child: _buildTopUpWithCustomerService(),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                spreadRadius: 1,
                                // blurRadius: 2,
                                offset:
                                    Offset(-5, 5), // changes position of shadow
                              ),
                            ],
                          ),
                          child: isWalletLoading
                              ? CupertinoActivityIndicator()
                              : Text(
                                  '${wallet.value} ${wallet.value > 1 ? 'coins' : 'coin'}',
                                  style: TextStyle(fontSize: 32)),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(
                        thickness: 2,
                        color: Colors.black,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(G.of(context).topuphistory,
                          style: Theme.of(context).textTheme.button),
                    ),
                    Divider(thickness: 2, color: Colors.black),
                    Expanded(
                      child: UserTransactionPage(),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }

  _showTopUpBtmSheet() {
    showToast('This Service is not available right now');
    // CustomBottomSheet.showTopUpBottomSheet(buildContext: context)
    //     .whenComplete(() => getUserWallet());
  }

  userReward() async {
    setState(() {
      isWalletLoading = true;
    });
    try {
      var msg = await MoonBlinkRepository.adReward();
      if (isDev) print(msg);
      await getUserWallet();
    } catch (err) {
      if (isDev) print(err);
    }
    setState(() {
      isWalletLoading = false;
    });
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

  // ignore: unused_element
  void _showRewardedAds() async {
    if (isAdLoading) return;
    setState(() {
      isAdLoading = true;
    });
    await RewardedVideoAd.instance
        .load(adUnitId: AdManager.rewardedAdId, targetingInfo: targetingInfo);
  }

  ///get user wallet
  Future<void> getUserWallet() async {
    setState(() {
      isWalletLoading = true;
    });
    try {
      Wallet wallet = await MoonBlinkRepository.getUserWallet();
      setState(() {
        this.wallet = wallet;
        isWalletLoading = false;
      });
    } catch (error) {
      if (isDev) print(error);
      setState(() {
        isWalletLoading = false;
      });
    }
  }
}

class ChoosePayDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      elevation: 2,
      title: Text('Choose Payment Method'),
      children: <Widget>[
        SimpleDialogOption(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pushNamed(context, RouteName.productListPage);
          },
          child: Container(
            child: Padding(
                padding: EdgeInsets.only(left: 18, bottom: 15),
                child: Text(
                  'MoonGo Pay',
                  style: Theme.of(context).textTheme.subtitle1,
                )),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.grey,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
        if (Platform.isAndroid)
          SimpleDialogOption(
            onPressed: () {
              showToast('GPay');
            },
            padding: EdgeInsets.zero,
            child: Container(
              child: Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: Text(
                    'Google Pay',
                    style: Theme.of(context).textTheme.subtitle1,
                  )),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Colors.grey,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ),
        if (Platform.isIOS)
          SimpleDialogOption(
            onPressed: () {
              showToast('Apple Pay');
            },
            padding: EdgeInsets.zero,
            child: Container(
              child: Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: Text(
                    'Apple Pay',
                    style: Theme.of(context).textTheme.subtitle1,
                  )),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Colors.grey,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
