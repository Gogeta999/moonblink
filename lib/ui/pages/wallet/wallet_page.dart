import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:oktoast/oktoast.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  // ignore: todo
  ///TODO: need to connect with backend.
  ///query List<IAPItem> from the store. IOS only
  // ignore: unused_field
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
  // ignore: unused_field
  List<PurchasedItem> _purchases = [];
  // ignore: unused_field
  List<PurchasedItem> _purchasedHistories = [];

  bool isLoading = false;

  Wallet wallet;

  bool hasError = false;

  @override
  void initState() {
    super.initState();
    asyncInitState(); //async is not allowed on initState() directly;
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
    //FlutterInappPurchase.instance.consumeAllItems;

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
        userTopUp(productItem.productId);
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
  }

  ///get user wallet
  Future<void> getUserWallet() async {
    try {
      Wallet wallet = await MoonBlinkRepository.getUserWallet();
      setState(() {
        this.wallet = wallet;
      });
    } catch (error) {
      setState(() {
        hasError = !hasError;
      });
    }
  }

  ///get IAP items.
  Future<void> getItems() async {
    List<IAPItem> items =
        await FlutterInappPurchase.instance.getProducts(_productLists);
    items
      ..sort((a, b) => double.tryParse(a.price) > double.tryParse(b.price)
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

  Widget _buildWalletList() {
    if (_items.isEmpty) {
      return ViewStateErrorWidget(
        error: ViewStateError(ViewStateErrorType.defaultError),
        onPressed: () => showToast('_items is Empty'),
      );
    } else if (wallet == null) {
      return ViewStateErrorWidget(
        error: ViewStateError(ViewStateErrorType.defaultError),
        onPressed: () => showToast('Wallet == null'),
      );
    } else if (hasError) {
      return ViewStateErrorWidget(
        error: ViewStateError(ViewStateErrorType.defaultError),
        onPressed: () => showToast('hasError'),
      );
    }else {
      return ListView.builder(
        itemCount: _items.length + 1,
        itemBuilder: (context, index) {
          return index == _items.length ? _buildCurrentCoinAmount() : _buildProductListTile(_items[index]);
        },
      );
    }

    return ListView.builder(
        itemCount: _items.length + 1,
        itemBuilder: (context, index) {
          return index == _items.length
              ? _buildCurrentCoinAmount()
              : _buildProductListTile(_items[index]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
      ),
      body: _buildWalletList(),
    );
  }
}
