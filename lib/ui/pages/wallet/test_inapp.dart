import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class TestInAPP extends StatefulWidget {
  @override
  _TestInAPPState createState() => _TestInAPPState();
}

class _TestInAPPState extends State<TestInAPP> {
  ///query List<IAPItem> from the store. IOS only
  var _iap = FlutterInappPurchase.instance.getAppStoreInitiatedProducts();

  ///to monitor the connection more thoroughly from 2.0.1.
  StreamSubscription _connectionSubscription;

  ///to monitor purchase event.
  StreamSubscription _purchaseUpdatedSubscription;

  ///to monitor purchase error event.
  StreamSubscription _purchaseErrorSubscription;

  final List<String> _productLists = [
    'coin_100',
    'coin_500',
    'coin_1000'
  ]; //for now only android
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];
  List<PurchasedItem> _purchasedHistories = [];

  @override
  void initState() {
    super.initState();
    asyncInitState(); //async is not allowed on initState() directly;
  }

  @override
  void dispose() {
    super.dispose();
    asyncDisposeState();
  }

  void asyncInitState() async {
    await FlutterInappPurchase.instance.initConnection;

    _connectionSubscription =
        FlutterInappPurchase.connectionUpdated.listen((connected) {
      print('connected: $connected');
    });

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      print('purchase-updated: $productItem');
      /*try {
        //consume after purchase success so user buy the product again.
        //need to connect with backend to process purchase.
        var msg = FlutterInappPurchase.instance.consumeAllItems;
        print('consumeAllItems: $msg');
      } catch (err) {
        print('consumeAllItems error: $err');
      }*/
      /*
      don't need to add this for now.
      setState(() {
        _purchases.add(productItem);
      });*/
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
    });

    //consumed all purchased item
    //await FlutterInappPurchase.instance.consumeAllItems;
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
  }

  ///get IAP items.
  Future<void> getItems() async {
    List<IAPItem> items =
        await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in items) {
      print('${item.toString()}');
      setState(() {
        this._items.add(item);
      });
    }
    setState(() {
      this._purchases.clear();
    });
  }

  ///get Purchased items.
  Future<void> getPurchasedItems() async {
    List<PurchasedItem> items =
        await FlutterInappPurchase.instance.getAvailablePurchases();
    for (var item in items) {
      print('${item.toString()}');
      setState(() {
        this._purchases.add(item);
      });
    }
    setState(() {
      this._items.clear();
    });
  }

  ///get PurchasedHistory items.
  Future<void> getPurchasedHistoryItems() async {
    List<PurchasedItem> items =
        await FlutterInappPurchase.instance.getPurchaseHistory();
    for (var item in items) {
      print('${item.toString()}');
      setState(() {
        this._purchasedHistories.add(item);
      });
    }
    setState(() {
      this._items.clear();
      this._purchases.clear();
    });
  }

  ///purchase IAP items.
  void purchaseItem(IAPItem item) async {
    var msg =
        await FlutterInappPurchase.instance.requestPurchase(item.productId);
    print('purchasedMsg: $msg');
  }

  void consumeAllProduct() async {
    try {
      //consume after purchase success so user buy the product again.
      //need to connect with backend to process purchase.
      var msg = FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }
  }

  Widget iApListViewBuilder() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('productId: ${_items[index].productId}'),
              Text('price: ${_items[index].price}'),
              Text('currency: ${_items[index].currency}'),
              Text('localizedPrice: ${_items[index].localizedPrice}'),
              Text('title: ${_items[index].title}'),
              Text('description: ${_items[index].description}'),
              Text('introductoryPrice: ${_items[index].introductoryPrice}'),
              //IOS only
              Text(
                  'subscriptionPeriodNumberIOS: ${_items[index].subscriptionPeriodNumberIOS}'),
              Text(
                  'subscriptionPeriodUnitIOS: ${_items[index].subscriptionPeriodUnitIOS}'),
              Text(
                  'introductoryPricePaymentModeIOS: ${_items[index].introductoryPricePaymentModeIOS}'),
              Text(
                  'introductoryPriceNumberOfPeriodsIOS: ${_items[index].introductoryPriceNumberOfPeriodsIOS}'),
              Text(
                  'introductoryPriceSubscriptionPeriodIOS: ${_items[index].introductoryPriceSubscriptionPeriodIOS}'),
              //Android only
              Text(
                  'subscriptionPeriodAndroid: ${_items[index].subscriptionPeriodAndroid}'),
              Text(
                  'introductoryPriceCyclesAndroid: ${_items[index].introductoryPriceCyclesAndroid}'),
              Text(
                  'introductoryPricePeriodAndroid: ${_items[index].introductoryPricePeriodAndroid}'),
              Text(
                  'freeTrialPeriodAndroid: ${_items[index].freeTrialPeriodAndroid}'),
              Text('signatureAndroid: ${_items[index].signatureAndroid}'),
              Text('iconUrl: ${_items[index].iconUrl}'),
              Text('originalJson: ${_items[index].originalJson}'),
              Text('originalPrice: ${_items[index].originalPrice}'),
              FlatButton(
                onPressed: () {
                  purchaseItem(_items[index]);
                },
                color: Theme.of(context).primaryColor,
                child: Text('Purchase This Product'),
              )
            ],
          ),
        );
      },
    );
  }

  Widget purchasedListViewBuilder() {
    return Column(
      children: <Widget>[
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _purchases.length,
          itemBuilder: (context, index) {
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text('productId: ${_purchases[index].productId}'),
                  Text('transactionId: ${_purchases[index].transactionId}'),
                  Text('transactionDate: ${_purchases[index].transactionDate}'),
                  Text(
                      'transactionReceipt: ${_purchases[index].transactionReceipt}'),
                  Text('purchaseToken: ${_purchases[index].purchaseToken}'),
                  Text('orderId: ${_purchases[index].orderId}'),
                  //IOS only
                  Text(
                      'originalTransactionDateIOS: ${_purchases[index].originalTransactionDateIOS}'),
                  Text(
                      'originalTransactionIdentifierIOS: ${_purchases[index].originalTransactionIdentifierIOS}'),
                  Text(
                      'transactionStateIOS: ${_purchases[index].transactionStateIOS}'),
                  //Android only
                  Text('dataAndroid: ${_purchases[index].dataAndroid}'),
                  Text(
                      'signatureAndroid: ${_purchases[index].signatureAndroid}'),
                  Text(
                      'autoRenewingAndroid: ${_purchases[index].autoRenewingAndroid}'),
                  Text(
                      'isAcknowledgedAndroid: ${_purchases[index].isAcknowledgedAndroid}'),
                  Text(
                      'purchaseStateAndroid: ${_purchases[index].purchaseStateAndroid}'),
                  Text(
                      'developerPayloadAndroid: ${_purchases[index].developerPayloadAndroid}'),
                  Text(
                      'originalJsonAndroid: ${_purchases[index].originalJsonAndroid}'),
                ],
              ),
            );
          },
        ),
        FlatButton(
          color: Theme.of(context).primaryColor,
          onPressed: consumeAllProduct,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text('Consume All Product'),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget purchasedHistoryListViewBuilder() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _purchasedHistories.length,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('productId: ${_purchasedHistories[index].productId}'),
              Text(
                  'transactionId: ${_purchasedHistories[index].transactionId}'),
              Text(
                  'transactionDate: ${_purchasedHistories[index].transactionDate}'),
              Text(
                  'transactionReceipt: ${_purchasedHistories[index].transactionReceipt}'),
              Text(
                  'purchaseToken: ${_purchasedHistories[index].purchaseToken}'),
              Text('orderId: ${_purchasedHistories[index].orderId}'),
              //IOS only
              Text(
                  'originalTransactionDateIOS: ${_purchasedHistories[index].originalTransactionDateIOS}'),
              Text(
                  'originalTransactionIdentifierIOS: ${_purchasedHistories[index].originalTransactionIdentifierIOS}'),
              Text(
                  'transactionStateIOS: ${_purchasedHistories[index].transactionStateIOS}'),
              //Android only
              Text('dataAndroid: ${_purchasedHistories[index].dataAndroid}'),
              Text(
                  'signatureAndroid: ${_purchasedHistories[index].signatureAndroid}'),
              Text(
                  'autoRenewingAndroid: ${_purchasedHistories[index].autoRenewingAndroid}'),
              Text(
                  'isAcknowledgedAndroid: ${_purchasedHistories[index].isAcknowledgedAndroid}'),
              Text(
                  'purchaseStateAndroid: ${_purchasedHistories[index].purchaseStateAndroid}'),
              Text(
                  'developerPayloadAndroid: ${_purchasedHistories[index].developerPayloadAndroid}'),
              Text(
                  'originalJsonAndroid: ${_purchasedHistories[index].originalJsonAndroid}'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter In App Purchase',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Inapp Plugin by dooboolab'),
        ),
        body: ListView(
          padding: EdgeInsets.all(10.0),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Flexible(
                  child: FlatButton(
                    onPressed: getItems,
                    child: Text('Get IAP Items'),
                  ),
                ),
                Flexible(
                  child: FlatButton(
                    onPressed: getPurchasedItems,
                    child: Text('Get Purchased Items'),
                  ),
                ),
                Flexible(
                  child: FlatButton(
                    onPressed: getPurchasedHistoryItems,
                    child: Text('Get Purchased Histories'),
                  ),
                )
              ],
            ),
            if (_items.isNotEmpty)
              iApListViewBuilder()
            else if (_purchases.isNotEmpty)
              purchasedListViewBuilder()
            else if (_purchasedHistories.isNotEmpty)
              purchasedHistoryListViewBuilder(),
          ],
        ),
      ),
    );
  }
}
