///Testing
//// Copyright 2019 The Chromium Authors. All rights reserved.
//// Use of this source code is governed by a BSD-style license that can be
//// found in the LICENSE file.
//
//import 'dart:async';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:moonblink/services/moonblink_repository.dart';
//import 'package:moonblink/utils/platform_utils.dart';
//
//const bool kAutoConsume = true;
//const Set<String> _kProductIds = <String>{
//  'coin_100',
//  'coin_500',
//  'coin_1000',
//};
//
//class MyApp extends StatefulWidget {
//  @override
//  _MyAppState createState() => _MyAppState();
//}
//
//// Subscribe to any incoming purchases at app initialization. These can
//// propagate from either storefront so it's important to listen as soon as
//// possible to avoid losing events.
//class _MyAppState extends State<MyApp> {
//  StreamSubscription<List<PurchaseDetails>> _subscription;
//
//  @override
//  void initState() {
//    super.initState();
//  }
//
//  @override
//  void dispose() {
//    _subscription.cancel();
//    super.dispose();
//  }
//
//  init() async {
//final QueryPurchaseDetailsResponse response =
//        await InAppPurchaseConnection.instance.queryPastPurchases();
//    if (response.error != null) {
//      // Handle the error.
//    }
//    for (PurchaseDetails purchase in response.pastPurchases) {
//      if (Platform.isIOS) {
//        print(purchase);
//        InAppPurchaseConnection.instance.completePurchase(purchase);
//      }
//    }
//
//    _subscription =
//        InAppPurchaseConnection.instance.purchaseUpdatedStream.listen((event) {
//          print(event);
//      event.forEach((PurchaseDetails purchaseDetails) async {
//        if (purchaseDetails.status == PurchaseStatus.pending) {
//          print('Purchasing');
//        } else {
//          if (purchaseDetails.status == PurchaseStatus.error) {
//            print(purchaseDetails.error.details);
//          } else if (purchaseDetails.status == PurchaseStatus.purchased) {
//            if (Platform.isAndroid) {
//              await InAppPurchaseConnection.instance
//                  .consumePurchase(purchaseDetails);
//
//              if (purchaseDetails.pendingCompletePurchase) {
//                BillingResultWrapper brw = await InAppPurchaseConnection
//                    .instance
//                    .completePurchase(purchaseDetails);
//                userTopUp(purchaseDetails.productID);
//              }
//            }
//          }
//        }
//      });
//    });
//  }
//
//  userTopUp(String productId) async {
//    try {
//      var msg = await MoonBlinkRepository.topUp(productId);
//      print(msg);
//      //await getUserWallet();
//    } catch (err) {
//      print(err);
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: FutureBuilder<bool>(
//        future: InAppPurchaseConnection.instance.isAvailable(),
//        builder: (context, snapshot) {
//          if (!snapshot.hasData) {
//            return CupertinoActivityIndicator();
//          } else if (!snapshot.data) {
//            return Text('Can\'t connect to the store.');
//          } else if (snapshot.data) {
//            init();
//            return ProductListTile();
//          } else {
//            return Text('Something went wrong!');
//          }
//        },
//      ),
//    );
//  }
//}
//
//class ProductListTile extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return FutureBuilder<ProductDetailsResponse>(
//      future:
//          InAppPurchaseConnection.instance.queryProductDetails(_kProductIds),
//      builder: (context, snapshot) {
//        if (!snapshot.hasData) {
//          return Center(child: CupertinoActivityIndicator());
//        } else {
//          snapshot.data.productDetails.forEach((element) {print(element.title);});
//          _sortProduct(snapshot.data.productDetails);
//          return ListView.builder(
//            itemCount: snapshot.data.productDetails.length,
//            itemBuilder: (context, index) {
//              return ListTile(
//                title: Text(snapshot.data.productDetails[index].title),
//                subtitle: Text(snapshot.data.productDetails[index].description),
//                trailing: CupertinoButton(
//                    onPressed: () =>
//                        _buyProduct(snapshot.data.productDetails[index]),
//                    child: Text(snapshot.data.productDetails[index].price)),
//              );
//            },
//          );
//        }
//      },
//    );
//  }
//
//  ///only for consumables
//  void _buyProduct(ProductDetails productDetails) async {
//    PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails, sandboxTesting: true);
//    InAppPurchaseConnection.instance.buyConsumable(purchaseParam: purchaseParam);
//  }
//
//  void _sortProduct(List<ProductDetails> list) {
//    if (Platform.isAndroid) {
//      list.sort((a, b) => double.tryParse(a.skuDetail.price) >
//              double.tryParse(b.skuDetail.price)
//          ? 1
//          : 0);
//    } else {
//      list.sort((a, b) => double.tryParse(a.skProduct.price) >
//              double.tryParse(b.skProduct.price)
//          ? 1
//          : 0);
//    }
//  }
//}
