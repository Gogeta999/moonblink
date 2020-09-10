import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:oktoast/oktoast.dart';

class TopUpBottomSheet extends StatefulWidget {
  @override
  _TopUpBottomSheetState createState() => _TopUpBottomSheetState();
}

class _TopUpBottomSheetState extends State<TopUpBottomSheet> {
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

  @override
  void initState() {
    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      print('Sorry: $error');
    });

    initStoreInfo();
    super.initState();
  }

  Future<void> initStoreInfo() async {
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
      print('Sorry: ${purchaseResponse.error}');
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

  Widget _buildConnectionCheckTile() {
    if (_loading) {
      return Container(
          margin: const EdgeInsets.all(8.0),
          child: ShadedContainer(
              child: Row(
                children: <Widget>[
                  CupertinoActivityIndicator(),
                  Text('Trying to connect...'),
                ],
              )));
    }

    ///(_isAvailable == false) showErrorWidgetWithRetry
    // final Widget storeHeader = ListTile(
    //   leading: Icon(_isAvailable ? Icons.check : Icons.block,
    //       color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
    //   title: Text(
    //       'The store is ' + (_isAvailable ? 'available' : 'unavailable') + '.'),
    // );
    final List<Widget> children = <Widget>[];

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

  Widget _buildProductList() {
    if (_loading) {
      return Container(
        margin: const EdgeInsets.all(8.0),
        child: ShadedContainer(
            child: (Row(children: <Widget>[
          CupertinoActivityIndicator(),
          Text('Fetching products...')
        ]))),
      );
    }
    if (!_isAvailable) {
      return Card();
    }
    //final ListTile productHeader = ListTile(title: Text('Products for Sale'));
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

    return Card(child: Column(children: <Widget>[] + productList));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              ShadedContainer(
                ontap: () => Navigator.pop(context, true),
                child: Text('Done'),
              ),
            ],
          ),
        ),
        _buildConnectionCheckTile(),
        _buildProductList()
      ],
    );
  }

  userTopUp(String productId) async {
    try {
      var msg = await MoonBlinkRepository.topUp(productId);
      print(msg);
    } catch (err) {
      print(err);
    }
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
          await userTopUp(purchaseDetails.productID);
        }
      }
    });
  }
}
