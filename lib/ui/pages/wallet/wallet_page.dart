import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/container/titleContainer.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/services/ad_manager.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _loading = false;

  @override
  void initState() {
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print("RewardedVideoAd event $event");
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

  Widget _buildAds() {
    return isAdLoading ? CupertinoActivityIndicator() : Text('Watch Ad');
  }

  Widget _buildTopUpWithCustomerService() {
    return Text('Customer service');
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
                      "My Coin",
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
                            ontap: () {
                              CustomBottomSheet.showTopUpBottomSheet(
                                      buildContext: context)
                                  .whenComplete(() => getUserWallet());
                            },
                            child: Text("Top Up"),
                          ),
                          ShadedContainer(
                            ontap: () {
                              print("cash");
                            },
                            child: Text("Cash Out"),
                          ),
                          ShadedContainer(
                            ontap: _showRewardedAds,
                            child: _buildAds(),
                          ),
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
                        height: 40,
                      ),
                      Divider(
                        height: 3,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "Top Up History",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  userReward() async {
    setState(() {
      isWalletLoading = true;
    });
    try {
      var msg = await MoonBlinkRepository.adReward();
      print(msg);
      await getUserWallet();
    } catch (err) {
      print(err);
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
      print(error);
      setState(() {
        isWalletLoading = false;
      });
    }
  }
}
