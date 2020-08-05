import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_native_admob/native_admob_options.dart';
import 'package:moonblink/ui/pages/wallet/topup_page.dart';

class TestNativeAds extends StatefulWidget {
  @override
  _TestNativeAdsState createState() => _TestNativeAdsState();
}

class _TestNativeAdsState extends State<TestNativeAds> {

  final _nativeAdController = NativeAdmobController();
  NativeAdmobOptions _nativeAdmobOptions;

  Color ratingColor;
  Color color;
  Color backgroundColor;

  @override
  void didChangeDependencies() {
    ratingColor = Theme.of(context).primaryColor;
    color = Theme.of(context).iconTheme.color;
    backgroundColor = Theme.of(context).accentColor;
    _nativeAdmobOptions = NativeAdmobOptions(
      showMediaContent: true,
      ratingColor: ratingColor,
      adLabelTextStyle: NativeTextStyle(
        fontSize: 14,
        color: color,
        backgroundColor: backgroundColor,
      ),
      headlineTextStyle:  NativeTextStyle(
        fontSize: 14,
        color: color,
        backgroundColor: backgroundColor,
      ),
      advertiserTextStyle:  NativeTextStyle(
        fontSize: 14,
        color: color,
        backgroundColor: backgroundColor,
      ),
      bodyTextStyle:  NativeTextStyle(
        fontSize: 14,
        color: color,
        backgroundColor: backgroundColor,
      ),
      storeTextStyle:  NativeTextStyle(
        fontSize: 14,
        color: color,
        backgroundColor: backgroundColor,
      ),
      priceTextStyle:  NativeTextStyle(
        fontSize: 14,
        color: color,
        backgroundColor: backgroundColor,
      ),
      callToActionStyle:  NativeTextStyle(
        fontSize: 14,
        color: color,
        backgroundColor: backgroundColor,
      ),
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              height: 200.0,
              color: Colors.green,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              height: 200.0,
              color: Colors.green,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              height: 200.0,
              color: Colors.green,
            ),
            Container(
              height: 90,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(bottom: 20.0),
              child: NativeAdmob(
                // Your ad unit id
                adUnitID: AdMobNativeAdUnitId,
                controller: _nativeAdController,
                type: NativeAdmobType.banner,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              height: 200.0,
              color: Colors.green,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              height: 200.0,
              color: Colors.green,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              height: 200.0,
              color: Colors.green,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              height: 200.0,
              color: Colors.green,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              height: 200.0,
              color: Colors.green,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              height: 200.0,
              color: Colors.green,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              height: 200.0,
              color: Colors.green,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              height: 200.0,
              color: Colors.green,
            ),
            Container(
              height: 330,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(bottom: 20.0),
              child: NativeAdmob(
                // Your ad unit id
                options: _nativeAdmobOptions,
                adUnitID: AdMobNativeAdUnitId,
                controller: _nativeAdController,
                type: NativeAdmobType.full,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
