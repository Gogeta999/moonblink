import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/payments/paymentMethod.dart';
import 'package:moonblink/models/payments/product.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/pages/payment/newtopuppage.dart';
import 'package:oktoast/oktoast.dart';

class NewProductListPage extends StatefulWidget {
  final String currentcoin;
  NewProductListPage({this.currentcoin});
  @override
  _NewProductListPageState createState() => _NewProductListPageState();
}

class _NewProductListPageState extends State<NewProductListPage> {
  final maxImageLimit = 2;
  //KBZ
  final _kbzpayIdWithSpaces = '1234 5678 9123 4567';
  final _kbzpayId = '09764033373';
  final _kbzpayTapGR = TapGestureRecognizer();
  final _kbzpayqr = "assets/images/kbzpayQR.jpeg";
  final _kbzpaysample = "assets/images/kbzpayexample.jpg";
  final _smallkbzapayqr = "assets/images/kbzqr.jpeg";
  //KBZ M Banking
  // final _kbzmbankingIdWithSpaces = '1234 1234 1234 1234';
  // final _kbzmbankingId = '1234123412341234';
  // final _kbzmbankingTapGR = TapGestureRecognizer();
  //Wave Money
  final _waveIdWithSpaces = '5678 5678 5678 5678';
  final _waveId = '09764033373';
  final _waveTapGR = TapGestureRecognizer();
  final _wavepayqr = "assets/images/wavepayQR.jpeg";
  final _smallwavepayqr = "assets/images/waveqr.jpeg";
  final _wavepaysample = "assets/images/wavepayexample.jpg";

  @override
  void initState() {
    _kbzpayTapGR.onTap = () {
      FlutterClipboard.copy(_kbzpayId)
          .then((value) => showToast(G.of(context).toastcopy));
    };
    // _kbzmbankingTapGR.onTap = () {
    //   FlutterClipboard.copy(_kbzmbankingId)
    //       .then((value) => showToast(G.of(context).toastcopy));
    // };
    _waveTapGR.onTap = () {
      FlutterClipboard.copy(_waveId)
          .then((value) => showToast(G.of(context).toastcopy));
    };
    super.initState();
  }

  Widget availablePlatformItem(
    String bankIdWithSpaces,
    TapGestureRecognizer tapGestureRecognizer, {
    Color color,
    Color textColor,
    String name,
    String description,
    String assetsName,
    String qrasset,
    Function onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Card(
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
                      qrasset,
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.12,
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: description,
                        style: Theme.of(context).textTheme.subtitle1,
                        children: [
                          TextSpan(
                            recognizer: tapGestureRecognizer,
                            text: bankIdWithSpaces,
                            style: TextStyle(
                                letterSpacing: 0.3,
                                color: Theme.of(context).accentColor,
                                fontSize: 15.0),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppbarWidget(
          title: Text(
            G.current.walletChoosePaymentTitle,
            style: Theme.of(context).textTheme.headline6,
          ),
          showActionIcon: false,
        ),
        body: Container(
          margin: const EdgeInsets.all(8.0),
          child: FutureBuilder<List<Product>>(
            initialData: [],
            future: MoonBlinkRepository.getProducts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: CupertinoButton(
                    child: Text(
                        '${snapshot.error}\n${G.current.viewStateButtonRetry}'),
                    onPressed: () {
                      setState(() {});
                    },
                  ),
                );
              }
              if (snapshot.data.isEmpty) {
                return Center(child: CupertinoActivityIndicator());
              }
              return ListView(
                physics: ClampingScrollPhysics(),
                children: [
                  availablePlatformItem(
                    _kbzpayId,
                    _kbzpayTapGR,
                    color: Colors.blue[200],
                    assetsName: _kbzpayqr,
                    qrasset: _smallkbzapayqr,
                    name: 'KBZPay',
                    onTap: () {
                      PaymentMethod method = PaymentMethod(
                        title: "KBZPay",
                        id: _kbzpayId,
                        image: _kbzpayqr,
                        smallimage: _smallkbzapayqr,
                        sample: _kbzpaysample,
                        method: G.current.paymentTopUpKpayMethod,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Newtopuppage(
                            product: snapshot.data,
                            method: method,
                          ),
                        ),
                      );
                    },
                    description: G.current.paymentTopUpKpayMethod,
                  ),
                  // availablePlatformItem(
                  //     _kbzmbankingIdWithSpaces, _kbzmbankingTapGR,
                  //     color: Colors.blue[200],
                  //     assetsName: 'assets/images/Later.jpg',
                  //     name: 'KBZ M Banking', onTap: () {
                  //   ///payment method
                  //   PaymentMethod method = PaymentMethod(
                  //     title: "KBZ M Banking",
                  //     id: "id",
                  //     image: "assets/images/Later.jpg",
                  //     method: "Open KBZ mBanking App.\nClick Transfer.\n",
                  //   );
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => Newtopuppage(
                  //         product: snapshot.data,
                  //         method: method,
                  //       ),
                  //     ),
                  //   );
                  // }, description: 'Open KBZ mBanking App.\nClick Transfer.\n'),
                  availablePlatformItem(
                    _waveId,
                    _waveTapGR,
                    color: Colors.yellow[200],
                    assetsName: _wavepayqr,
                    qrasset: _smallwavepayqr,
                    textColor: Colors.black,
                    name: 'Wave Money',
                    onTap: () {
                      PaymentMethod method = PaymentMethod(
                        title: "Wave Money",
                        id: _waveId,
                        image: _wavepayqr,
                        smallimage: _smallwavepayqr,
                        method: G.current.paymentTopUpWavepayMethod,
                        sample: _wavepaysample,
                        recognizer: _waveTapGR,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Newtopuppage(
                            product: snapshot.data,
                            method: method,
                          ),
                        ),
                      );
                    },
                    description: G.current.paymentTopUpKpayMethod,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      G.current.currentcoin + ": ${widget.currentcoin}",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
