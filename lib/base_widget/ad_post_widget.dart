import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_native_admob/native_admob_options.dart';
import 'package:moonblink/services/ad_manager.dart';

class AdPostWidget extends StatefulWidget {
  @override
  _AdPostWidgetState createState() => _AdPostWidgetState();
}

class _AdPostWidgetState extends State<AdPostWidget> {
  final _nativeAdController = NativeAdmobController();
  NativeAdmobOptions _nativeAdmobOptions;

  @override
  void dispose() {
    _nativeAdController.dispose();
    super.dispose();
  }

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
    return Column(
      children: <Widget>[
        Container(
          child: NativeAdmob(
            options: _nativeAdmobOptions,
            adUnitID: AdManager.nativeAdId,
            controller: _nativeAdController,
            type: NativeAdmobType.full,
          ),
        ),
        Divider(
          height: 0.5,
        )
      ],
    );
  }
}
