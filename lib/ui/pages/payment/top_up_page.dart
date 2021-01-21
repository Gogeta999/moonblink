import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/payments/product.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/compress_utils.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/subjects.dart';

class TopUpPage extends StatefulWidget {
  final Product product;

  const TopUpPage({Key key, this.product})
      : assert(product != null),
        super(key: key);
  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final _transactionImageSubject = BehaviorSubject<File>();
  final _submitSubject = BehaviorSubject.seeded(false);
  //KBZ
  final _kbzpayIdWithSpaces = '1234 5678 9123 4567';
  final _kbzpayId = '1234567891234567';
  final _kbzpayTapGR = TapGestureRecognizer();
  //KBZ M Banking
  final _kbzmbankingIdWithSpaces = '1234 1234 1234 1234';
  final _kbzmbankingId = '1234123412341234';
  final _kbzmbankingTapGR = TapGestureRecognizer();
  //Wave Money
  final _waveIdWithSpaces = '5678 5678 5678 5678';
  final _waveId = '5678567856785678';
  final _waveTapGR = TapGestureRecognizer();

  @override
  void initState() {
    _kbzpayTapGR.onTap = () {
      FlutterClipboard.copy(_kbzpayId)
          .then((value) => showToast(G.of(context).toastcopy));
    };
    _kbzmbankingTapGR.onTap = () {
      FlutterClipboard.copy(_kbzmbankingId)
          .then((value) => showToast(G.of(context).toastcopy));
    };
    _waveTapGR.onTap = () {
      FlutterClipboard.copy(_waveId)
          .then((value) => showToast(G.of(context).toastcopy));
    };
    super.initState();
  }

  @override
  void dispose() {
    _submitSubject.close();
    _transactionImageSubject.close();
    super.dispose();
  }

  Widget availablePlatformItem(
      String bankIdWithSpaces, TapGestureRecognizer tapGestureRecognizer,
      {Color color,
      Color textColor,
      String name,
      String description,
      String assetsName}) {
    return Card(
      elevation: 10.0,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: MediaQuery.of(context).size.width * 0.7,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0)),
                    color: color),
                child: Text(
                  name,
                  textAlign: TextAlign.start,
                  style: TextStyle(color: textColor),
                )),
            SizedBox(height: 5),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            fullscreenDialog: true,
                            builder: (_) =>
                                FullScreenImageView(assetsName: assetsName)));
                  },
                  child: Image.asset(
                    assetsName,
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.12,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: RichText(
                      text: TextSpan(text: description, children: [
                    TextSpan(
                        recognizer: tapGestureRecognizer,
                        text: bankIdWithSpaces,
                        style: TextStyle(
                            letterSpacing: 0.3,
                            color: Theme.of(context).accentColor,
                            fontSize: 18.0))
                  ])),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  _showSelectImageOptions() {
    return showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (builder) => CupertinoAlertDialog(
        content: Text(G.of(context).pickimage),
        actions: <Widget>[
          ///Gallery
          CupertinoButton(
              child: Text(G.of(context).imagePickerGallery),
              onPressed: () {
                CustomBottomSheet.show(
                    buildContext: context,
                    limit: 1,
                    body: 'Select Screenshot',
                    onPressed: (List<File> files) {
                      this._transactionImageSubject.add(files.first);
                    },
                    buttonText: G.of(context).select,
                    popAfterBtnPressed: true,
                    requestType: RequestType.image,
                    willCrop: false,
                    compressQuality: NORMAL_COMPRESS_QUALITY);
                Navigator.pop(context);
              }),

          ///Camera
          CupertinoButton(
              child: Text(G.of(context).imagePickerCamera),
              onPressed: () async {
                Navigator.pop(context);
                PickedFile pickedFile =
                    await ImagePicker().getImage(source: ImageSource.camera);
                File compressedImage = await CompressUtils.compressAndGetFile(
                    File(pickedFile.path), NORMAL_COMPRESS_QUALITY, 1080, 1080);
                this._transactionImageSubject.add(compressedImage);
              }),
          CupertinoButton(
            child: Text(G.of(context).cancel),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  _topup() async {
    final screenshot = await _transactionImageSubject.first;
    if (screenshot == null) {
      showToast('Require screenshot');
      return;
    }
    _submitSubject.add(true);
    MoonBlinkRepository.postPayment(widget.product.id, screenshot).then(
        (value) {
      _submitSubject.add(false);
      Navigator.pop(context);
      showToast('Success');
    }, onError: (e) {
      _submitSubject.add(false);
      showToast('$e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppbarWidget(
            title: Text('TopUp'),
          ),
          body: Container(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 5),
                //Text('Upload your transfer Photo & Description'),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.black45),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Selected Product -> MoonBlink Coins - ${widget.product.mbCoin}'),
                      Text(
                          'Amount To Transfer -> ${widget.product.value} ${widget.product.currencyCode}'),
                    ],
                  ),
                ),
                Divider(indent: 5, endIndent: 5, thickness: 2),
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Row(
                    children: [
                      ///ScreenShot
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: StreamBuilder<File>(
                            initialData: null,
                            stream: _transactionImageSubject,
                            builder: (context, snapshot) {
                              if (snapshot.data == null) {
                                return Text(
                                  'Your Screenshot will appear here.',
                                  textAlign: TextAlign.center,
                                );
                              }
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          fullscreenDialog: true,
                                          builder: (_) => FullScreenImageView(
                                              image: snapshot.data)));
                                },
                                child: Image.file(
                                  snapshot.data,
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      /// Submit and Description
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Transfer amount & Description'),
                              Divider(indent: 5, endIndent: 5, thickness: 2),
                              Text('? Click To Show Example Format'),
                              SizedBox(height: 10),
                              StreamBuilder<bool>(
                                  initialData: false,
                                  stream: _submitSubject,
                                  builder: (context, snapshot) {
                                    if (snapshot.data) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 4.0),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .accentColor),
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                        child: CupertinoActivityIndicator(),
                                      );
                                    }
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(15.0),
                                      onTap: () {
                                        _topup();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 4.0),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .accentColor),
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                        child: Text('Submit',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor,
                                                fontSize: 16.0)),
                                      ),
                                    );
                                  })
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10),

                /// Add a screenshot
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () {
                      _showSelectImageOptions();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).accentColor),
                          borderRadius: BorderRadius.circular(15.0)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 5),
                          Text('Add a screenshot',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 16.0)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                    'P.S: Please add a detailed screenshot for quicker topup.'),
                Divider(indent: 5, endIndent: 5, thickness: 2),
                Text('Available TopUp Platform'),
                SizedBox(height: 10),
                Expanded(
                    child: ListView(
                  physics: ClampingScrollPhysics(),
                  children: [
                    availablePlatformItem(_kbzpayIdWithSpaces, _kbzpayTapGR,
                        color: Colors.blue[900],
                        assetsName: 'assets/images/Later.jpg',
                        name: 'KBZPay',
                        description:
                            'Open KBZPay.\nScan QR to pay or manual with this number.\n'),
                    availablePlatformItem(
                        _kbzmbankingIdWithSpaces, _kbzmbankingTapGR,
                        color: Colors.blue[900],
                        assetsName: 'assets/images/Later.jpg',
                        name: 'KBZ M Banking',
                        description:
                            'Open KBZ mBanking App.\nClick Transfer.\n'),
                    availablePlatformItem(_waveIdWithSpaces, _waveTapGR,
                        color: Colors.yellow[300],
                        assetsName: 'assets/images/Later.jpg',
                        textColor: Colors.black,
                        name: 'Wave Money',
                        description: 'Open Wave Money App.\nClick ...\n'),
                  ],
                ))
              ],
            ),
          )),
    );
  }
}
