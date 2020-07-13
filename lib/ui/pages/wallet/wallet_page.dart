import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  ///TODO need to connect with backend.
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
      try {
        //consume after purchase success so user buy the product again.
        //need to connect with backend to process purchase.
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

    await getItems();

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
    items..sort((a, b) => double.tryParse(a.price) > double.tryParse(b.price)
        ? 1
        : 0); //sort by price;
    setState(() {
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
      var msg = FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }
  }

  Widget _buildProductListTile(IAPItem iapItem) {
    return Container(
        alignment: Alignment.center,
        // // color: Colors.grey,
        margin: EdgeInsets.all(10),
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Colors.grey),
          // color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: ListTile(
          leading: Icon(
            FontAwesomeIcons.coins,
            color: Theme.of(context).iconTheme.color,
          ),
          title: Text('${iapItem.description}'),
          subtitle: Text('${iapItem.price} ${iapItem.currency}'),
          trailing: FlatButton(
              color: Theme.of(context).accentColor,
              child: Text('Top Up',
                  style: Theme.of(context).accentTextTheme.button),
              onPressed: () => purchaseItem(iapItem)),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return _buildProductListTile(_items[index]);
        },
      ),
    );
  }
}
