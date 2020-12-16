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
      headlineTextStyle: NativeTextStyle(
        fontSize: 14,
        color: color,
        backgroundColor: backgroundColor,
      ),
      advertiserTextStyle: NativeTextStyle(
        fontSize: 14,
        color: color,
        backgroundColor: backgroundColor,
      ),
      bodyTextStyle: NativeTextStyle(
        fontSize: 14,
        color: color,
        backgroundColor: backgroundColor,
      ),
      storeTextStyle: NativeTextStyle(
        fontSize: 14,
        color: color,
        backgroundColor: backgroundColor,
      ),
      priceTextStyle: NativeTextStyle(
        fontSize: 14,
        color: color,
        backgroundColor: backgroundColor,
      ),
      callToActionStyle: NativeTextStyle(
        fontSize: 14,
        color: color,
        backgroundColor: backgroundColor,
      ),
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 2.0,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey
              : Colors.black,
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              /// [user_Profile]
              Container(
                height: 40,
              ),

              /// [User_Image]

              Column(
                children: <Widget>[
                  InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 2,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey
                                    : Colors.black,
                          ),
                          bottom: BorderSide(
                            width: 2,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey
                                    : Colors.black,
                          ),
                        ),
                      ),
                      constraints: BoxConstraints(
                          minHeight: 330,
                          maxHeight: 330,
                          minWidth: double.infinity,
                          maxWidth: double.infinity),
                      child: NativeAdmob(
                        options: _nativeAdmobOptions,
                        adUnitID: AdManager.nativeAdId,
                        controller: _nativeAdController,
                        type: NativeAdmobType.full,
                      ),
                    ),
                  ),

                  /// [User_bottom data]
                  Container(
                    height: 30,
                    width: double.infinity,
                    margin: EdgeInsets.all(8.0),
                    child: Stack(
                      children: <Widget>[],
                    ),
                  )
                ],
              ),

              /// [bottom date]

              Divider(
                height: 5,
              ),
            ],
          ),
        ],
      ),
    );
    // return Column(
    //   children: <Widget>[
    //     Container(
    //       height: 330,
    //       child: NativeAdmob(
    //         options: _nativeAdmobOptions,
    //         adUnitID: AdManager.nativeAdId,
    //         controller: _nativeAdController,
    //         type: NativeAdmobType.full,
    //       ),
    //     ),
    //     Divider(
    //       height: 0.5,
    //     )
    //   ],
    // );
  }
}
