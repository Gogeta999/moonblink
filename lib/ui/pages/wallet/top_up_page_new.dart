///in_app_purchase
import 'dart:async';
import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/services/ad_manager.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';

///Emulators are always treated as test devices
const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['game', 'entertainment'],
  contentUrl: 'https://moonblinkunivsere.com',
  nonPersonalizedAds: true,
);

class TopUpPageNew extends StatefulWidget {
  @override
  _TopUpPageNew createState() => _TopUpPageNew();
}

class _TopUpPageNew extends State<TopUpPageNew>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ///Constants
  final bool kAutoConsume = true;
  final String coin200Consumable =
      Platform.isAndroid ? 'coin_200' : 'coin_200_ios';
  final String coin500Consumable = 'coin_500';
  final String coin1000Consumable = 'coin_1000';
  final List<String> _kProductIds = <String>[
    Platform.isAndroid ? 'coin_200' : 'coin_200_ios',
    'coin_500',
    'coin_1000'
  ];

  ///Properties
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  //List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;

  Wallet wallet = Wallet(value: 0);
  bool isLoading = false;
  bool isAdLoading = false;

  @override
  void initState() {
    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      if (isDev) print('Sorry: $error');
    });

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

    initStoreInfo();
    super.initState();
  }

  Future<void> initStoreInfo() async {
    getUserWallet();

    setState(() {
      _notFoundIds = [];
      _products = [];
      _purchases = [];
      _isAvailable = false;
      _purchasePending = false;
      _loading = true;
      _queryProductError = null;
    });
    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _notFoundIds = [];
        //_consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    ProductDetailsResponse productDetailResponse =
        await _connection.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        //_consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        //_consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final QueryPurchaseDetailsResponse purchaseResponse =
        await _connection.queryPastPurchases();
    if (purchaseResponse.error != null) {
      if (isDev) print('Sorry: ${purchaseResponse.error}');
    }
    final List<PurchaseDetails> verifiedPurchases = [];
    for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
      if (await _verifyPurchase(purchase)) {
        verifiedPurchases.add(purchase);
      }
    }

    _sortProduct(productDetailResponse.productDetails);
    //List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = verifiedPurchases;
      _notFoundIds = productDetailResponse.notFoundIDs;
      //_consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<Widget> stack = [];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: [
            _buildConnectionCheckTile(),
            _buildProductList(),
            _buildCurrentCoin(),
            _buildAds(),
            if (Platform.isAndroid) _buildTopUpWithCustomerService()
            //_buildConsumableBox(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_queryProductError),
            CupertinoButton(
              onPressed: () async {
                await initStoreInfo();
              },
              child: Text('Retry'),
            )
          ],
        ),
      ));
    }
    if (_purchasePending) {
      stack.add(
        Stack(
          children: [
            Opacity(
              opacity: 0.3,
              child: const ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CupertinoActivityIndicator(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushNamedAndRemoveUntil(
              context, RouteName.main, (route) => false,
              arguments: 3);
          return false;
        },
        child: Stack(
          children: stack,
        ),
      ),
    );
  }

  Card _buildConnectionCheckTile() {
    if (_loading) {
      return Card(child: ListTile(title: const Text('Trying to connect...')));
    }
    final Widget storeHeader = ListTile(
      leading: Icon(_isAvailable ? Icons.check : Icons.block,
          color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
      title: Text(
          'The store is ' + (_isAvailable ? 'available' : 'unavailable') + '.'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll([
        Divider(),
        ListTile(
          title: Text('Not connected',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Card _buildProductList() {
    if (_loading) {
      return Card(
          child: (ListTile(
              leading: CupertinoActivityIndicator(),
              title: Text('Fetching products...'))));
    }
    if (!_isAvailable) {
      return Card();
    }
    final ListTile productHeader = ListTile(title: Text('Products for Sale'));
    List<ListTile> productList = <ListTile>[];
    if (_notFoundIds.isNotEmpty) {
      productList.add(ListTile(
          title: Text('[${_notFoundIds.join(", ")}] not found',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: Text(
              'This app needs special configuration to run. Please see example/README.md for instructions.')));
    }

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verity the purchase data.
    Map<String, PurchaseDetails> purchases =
        Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        PurchaseDetails previousPurchase = purchases[productDetails.id];
        return ListTile(
            title: Text(
              productDetails.title,
            ),
            subtitle: Text(
              productDetails.description,
            ),
            trailing: previousPurchase != null
                ? Icon(Icons.check)
                : FlatButton(
                    child: Text(productDetails.price),
                    color: Colors.green[800],
                    textColor: Colors.white,
                    onPressed: () {
                      PurchaseParam purchaseParam = PurchaseParam(
                          productDetails: productDetails,
                          applicationUserName: null,

                          ///production sandboxTesting false
                          sandboxTesting: false);
                      if (productDetails.id == coin200Consumable ||
                          productDetails.id == coin500Consumable ||
                          productDetails.id == coin1000Consumable) {
                        _connection.buyConsumable(
                            purchaseParam: purchaseParam,
                            autoConsume: kAutoConsume || Platform.isIOS);
                      } else {
                        _connection.buyNonConsumable(
                            purchaseParam: purchaseParam);
                      }
                    },
                  ));
      },
    ));

    return Card(
        child:
            Column(children: <Widget>[productHeader, Divider()] + productList));
  }

  Card _buildCurrentCoin() {
    return Card(
      child: _loading
          ? Center(
              child: Container(
                  margin: EdgeInsets.all(16.0),
                  child: CupertinoActivityIndicator()))
          : ListTile(
              leading: Icon(
                FontAwesomeIcons.coins,
                color: Colors.amber[500],
              ),
              title: Text(
                  'Current coin : ${wallet.value} ${wallet.value > 1 ? 'coins' : 'coin'}'),
              trailing: isLoading ? CupertinoActivityIndicator() : null,
            ),
    );
  }

  Card _buildAds() {
    return Card(
      child: _loading
          ? Center(
              child: Container(
                  margin: EdgeInsets.all(16.0),
                  child: CupertinoActivityIndicator()))
          : ListTile(
              onTap: _showRewardedAds,
              leading: Icon(
                FontAwesomeIcons.ad,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text('Watch an Ad to get free coins.'),
              trailing: isAdLoading ? CupertinoActivityIndicator() : null,
            ),
    );
  }

  Card _buildTopUpWithCustomerService() {
    return Card(
      child: _loading
          ? Center(
              child: Container(
                  margin: EdgeInsets.all(16.0),
                  child: CupertinoActivityIndicator()))
          : ListTile(
              onTap: _openFacebookPage,
              leading: Icon(
                FontAwesomeIcons.handsHelping,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text('Top up with our customer service.'),
              trailing: Icon(
                FontAwesomeIcons.facebook,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
    );
  }

  /*Card _buildConsumableBox() {
    if (_loading) {
      return Card(
          child: (ListTile(
              leading: CupertinoActivityIndicator(),
              title: Text('Fetching consumables...'))));
    }
    if (!_isAvailable || _notFoundIds.contains('coin_200_ios') || _notFoundIds.contains('coin_500') || _notFoundIds.contains('coin_1000')) {
      return Card();
    }
    final ListTile consumableHeader =
    ListTile(title: Text('Purchased consumables'));
    final List<Widget> tokens = _consumables.map((String id) {
      return GridTile(
        child: IconButton(
          icon: Icon(
            Icons.stars,
            size: 42.0,
            color: Colors.orange,
          ),
          splashColor: Colors.yellowAccent,
          onPressed: () => consume(id),
        ),
      );
    }).toList();
    return Card(
        child: Column(children: <Widget>[
          consumableHeader,
          Divider(),
          GridView.count(
            crossAxisCount: 5,
            children: tokens,
            shrinkWrap: true,
            padding: EdgeInsets.all(16.0),
          )
        ]));
  }

  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _consumables = consumables;
    });
  }*/

  ///get user wallet
  Future<void> getUserWallet() async {
    try {
      Wallet wallet = await MoonBlinkRepository.getUserWallet();
      setState(() {
        this.wallet = wallet;
      });
    } catch (error) {
      if (isDev) print(error);
    }
  }

  userTopUp(String productId) async {
    setState(() {
      isLoading = true;
    });
    try {
      var msg = await MoonBlinkRepository.topUp(productId);
      if (isDev) print(msg);
      await getUserWallet();
    } catch (err) {
      if (isDev) print(err);
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
      if (isDev) print(msg);
      await getUserWallet();
    } catch (err) {
      if (isDev) print(err);
    }
    setState(() {
      isLoading = false;
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

  void _sortProduct(List<ProductDetails> list) {
    if (Platform.isAndroid) {
      list.sort((a, b) =>
          a.skuDetail.priceAmountMicros > b.skuDetail.priceAmountMicros
              ? 1
              : 0);
    } else {
      list.sort((a, b) => double.tryParse(a.skProduct.price) >
              double.tryParse(b.skProduct.price)
          ? 1
          : 0);
    }
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify a purchase purchase details before delivering the product.
    if (purchaseDetails.productID == coin200Consumable ||
        purchaseDetails.productID == coin500Consumable ||
        purchaseDetails.productID == coin1000Consumable) {
      //await ConsumableStore.save(purchaseDetails.purchaseID);
      //List<String> consumables = await ConsumableStore.load();
      setState(() {
        _purchasePending = false;
      });
    } else {
      setState(() {
        _purchases.add(purchaseDetails);
        _purchasePending = false;
      });
    }
  }

  void handleError(IAPError error) {
    showToast(error.message);
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!kAutoConsume && purchaseDetails.productID == coin200Consumable ||
              purchaseDetails.productID == coin500Consumable ||
              purchaseDetails.productID == coin1000Consumable) {
            await InAppPurchaseConnection.instance
                .consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchaseConnection.instance
              .completePurchase(purchaseDetails);
          setState(() {
            userTopUp(purchaseDetails.productID);
          });
        }
      }
    });
  }
}
