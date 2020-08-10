import 'dart:async';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/ad_manager.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:url_launcher/url_launcher.dart';

///Emulators are always treated as test devices
const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['game', 'entertainment'],
  contentUrl: 'https://moonblinkunivsere.com',
  nonPersonalizedAds: true,
);

class TopUpPage extends StatefulWidget {
  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ///query List<IAPItem> from the store. IOS only
  // ignore: unused_field
  //var _iap = FlutterInappPurchase.instance.getAppStoreInitiatedProducts();

  ///to monitor the connection more thoroughly from 2.0.1.
  StreamSubscription _connectionSubscription;

  ///to monitor purchase event.
  StreamSubscription _purchaseUpdatedSubscription;

  ///to monitor purchase error event.
  StreamSubscription _purchaseErrorSubscription;

  final List<String> _productLists = [
    'coin_200',
    'coin_500',
    'coin_1000'
  ]; //for now only android
  List<IAPItem> _items = [];
  // ignore: unused_field
  List<PurchasedItem> _purchases = [];
  // ignore: unused_field
  List<PurchasedItem> _purchasedHistories = [];

  bool isLoading = false;
  bool isAdLoading = false;

  Wallet wallet = Wallet(value: 0);

  @override
  void initState() {
    asyncInitState();
    super.initState();
  }

  @override
  void dispose() {
    asyncDisposeState();
    super.dispose();
  }

  void asyncInitState() async {
    await FlutterInappPurchase.instance.initConnection;
    await getItems();
    await getUserWallet();

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

    _connectionSubscription =
        FlutterInappPurchase.connectionUpdated.listen((connected) {
      print('connected: $connected');
    });

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      print('purchase-updated: $productItem');
      try {
        //consume after purchase success so user buy the product again.
        //need to connect with backend to process purchase.
        //userTopUp(productItem.productId);
        setState(() {
          //userWallet.topUp(productItem.productId);
          userTopUp(productItem.productId);
        });
        var msg = FlutterInappPurchase.instance.consumeAllItems;
        print('consumeAllItems: $msg');
      } catch (err) {
        print('consumeAllItems error: $err');
      }
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
    });
  }

  ///You should end the billing service in android when you are done with it.
  /// Otherwise it will be keep running in background.
  /// We recommend to use this feature in dispose().
  void asyncDisposeState() async {
    //remove all Listeners and Streams
    await FlutterInappPurchase.instance.endConnection;
    if (_connectionSubscription != null) {
      _connectionSubscription.cancel();
      _connectionSubscription = null;
    }
    if (_purchaseUpdatedSubscription != null) {
      _purchaseUpdatedSubscription.cancel();
      _purchaseErrorSubscription = null;
    }
    if (_purchaseErrorSubscription != null) {
      _purchaseErrorSubscription.cancel();
      _purchaseErrorSubscription = null;
    }
    if(RewardedVideoAd.instance.listener != null) {
      RewardedVideoAd.instance.listener = null;
    }
  }

  ///get user wallet
  Future<void> getUserWallet() async {
    try {
      Wallet wallet = await MoonBlinkRepository.getUserWallet();
      setState(() {
        this.wallet = wallet;
      });
    } catch (error) {
      print(error);
    }
  }

  ///get IAP items.
  Future<void> getItems() async {
    List<IAPItem> items =
        await FlutterInappPurchase.instance.getProducts(_productLists);
    items.sort((a, b) => double.tryParse(a.price) > double.tryParse(b.price)
        ? 1
        : 0); //sort by price;
    this.setState(() {
      this._items = items;
    });
    for (var item in items) {
      print('${item.toString()}');
    }
  }

  ///get Purchased items.
  Future<void> getPurchasedItems() async {
    List<PurchasedItem> items =
        await FlutterInappPurchase.instance.getAvailablePurchases();
    setState(() {
      this._purchases = items;
    });
    for (var item in items) {
      print('${item.toString()}');
    }
  }

  ///get PurchasedHistory items.
  Future<void> getPurchasedHistoryItems() async {
    List<PurchasedItem> items =
        await FlutterInappPurchase.instance.getPurchaseHistory();
    setState(() {
      this._purchasedHistories = items;
    });
    for (var item in items) {
      print('${item.toString()}');
    }
  }

  ///purchase IAP items.
  purchaseItem(IAPItem iapItem) async {
    var msg =
        await FlutterInappPurchase.instance.requestPurchase(iapItem.productId);
    print('purchasedMsg: $msg');
  }

  consumeAllProduct() async {
    try {
      //consume after purchase success so user buy the product again.
      //need to connect with backend to process purchase.
      var msg = await FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }
  }

  userTopUp(String productId) async {
    setState(() {
      isLoading = true;
    });
    try {
      var msg = await MoonBlinkRepository.topUp(productId);
      print(msg);
      await getUserWallet();
    } catch (err) {
      print(err);
    }
    setState(() {
      isLoading = false;
    });
  }

  userReward() async {
    setState(() {
      isLoading = true;
    });
    try {
      var msg = await MoonBlinkRepository.adReward();
      print(msg);
      await getUserWallet();
    }catch (err) {
      print(err);
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget _buildProductListTile(IAPItem iapItem) {
    return Container(
        alignment: Alignment.center,
        // // color: Colors.grey,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: Colors.grey),
          // color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        child: ListTile(
          leading: Icon(
            FontAwesomeIcons.coins,
            color: Colors.amber[500],
          ),
          title: Text('${iapItem.description}'),
          subtitle: Text('${iapItem.price} ${iapItem.currency}'),
          trailing: RaisedButton(
              color: Theme.of(context).accentColor,
              child: Text('Top Up',
                  style: Theme.of(context).accentTextTheme.button),
              onPressed: () => purchaseItem(iapItem)),
        ));
  }

  Widget _buildCurrentCoinAmount() {
    return Container(
        alignment: Alignment.center,
        // // color: Colors.grey,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: Colors.grey),
          // color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        child: ListTile(
          leading: Icon(
            FontAwesomeIcons.coins,
            color: Colors.amber[500],
          ),
          title: Text(
              'Current coin : ${wallet.value} ${wallet.value > 1 ? 'coins' : 'coin'}'),
          trailing: isLoading ? CircularProgressIndicator() : null,
        ));
  }

  Widget _buildTopUpWithCustomerService() {
    return InkResponse(
      onTap: _openFacebookPage,
      child: Container(
          alignment: Alignment.center,
          // // color: Colors.grey,
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(width: 1.5, color: Colors.grey),
            // color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          child: ListTile(
            leading: Icon(
              FontAwesomeIcons.handsHelping,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text('Top up with our customer service.'),
            trailing: Icon(
              FontAwesomeIcons.facebook,
              color: Theme.of(context).iconTheme.color,
            ),
          )),
    );
  }

  Widget _buildAds() {
    return InkResponse(
      onTap: _showRewardedAds,
      child: Container(
          alignment: Alignment.center,
          // // color: Colors.grey,
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(width: 1.5, color: Colors.grey),
            // color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          child: ListTile(
            leading: Icon(
              FontAwesomeIcons.ad,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text('Watch an Ad to get free coins.'),
            trailing: isAdLoading ? CircularProgressIndicator() : null,
          )),
    );
  }

  Widget _buildWalletList() {
    if (_items.isEmpty || wallet == null) {
      return ViewStateErrorWidget(
        error: ViewStateError(ViewStateErrorType.defaultError),
        onPressed: () => {getItems(), getUserWallet() /*userWallet.refresh()*/},
      );
    } else {
      return Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _buildProductListTile(_items[index]);
              },
            ),
          ),
          _buildCurrentCoinAmount(),
          _buildAds(),
          _buildTopUpWithCustomerService()
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, RouteName.main ,(route) => false, arguments: 3);
        return false;
      },
      child: _buildWalletList()
    );
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
    setState(() {
      isAdLoading = true;
    });
    await RewardedVideoAd.instance.load(adUnitId: AdManager.rewardedAdId, targetingInfo: targetingInfo);
  }
}
