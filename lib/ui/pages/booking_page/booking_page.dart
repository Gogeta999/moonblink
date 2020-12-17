import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/base_widget/intro/flutter_intro.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/booking_partner_game_list.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/ui/helper/tutorial.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

class BookingPage extends StatefulWidget {
  final int partnerId;
  final String partnerName;
  final String partnerProfile;
  final String partnerBios;
  BookingPage(
      {Key key,
      // this.partnerUser,
      this.partnerId,
      this.partnerName,
      this.partnerProfile,
      this.partnerBios})
      : super(key: key);
  // final PartnerUser partnerUser;
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int _price = 0;
  Intro intro;
  List<Widget> _gameNameList = [];
  List<Widget> _gameModeList = [];
  BookingPartnerGameList _data;
  String _selectedGameName = '';
  String _selectedGameMode = '';
  Wallet _wallet;
  var error;

  TextStyle _textStyle;
  bool _isPageLoading = false;
  bool _isPageError = false;
  bool _isConfirmLoading = false;

  BehaviorSubject<int> _matchSubject = BehaviorSubject.seeded(0);
  BehaviorSubject<int> _totalPriceSubject = BehaviorSubject.seeded(0);

  ///send back to server
  int _gameTypeId = 0;

  _BookingPageState() {
    intro = Intro(
      stepCount: 6,
      borderRadius: BorderRadius.circular(15),

      /// use defaultTheme, or you can implement widgetBuilder function yourself
      widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        texts: [
          G.current.tutorialBooking1,
          G.current.tutorialBooking2,
          G.current.tutorialBooking3,
          G.current.tutorialBooking4,
          G.current.tutorialBooking5,
          G.current.tutorialBooking6,
        ],
        buttonTextBuilder: (curr, total) {
          return curr < total - 1 ? 'Next' : 'Finish';
        },
      ),
    );
  }

  @override
  void initState() {
    _initData();
    bool tuto = (StorageManager.sharedPreferences.getBool(bookingtuto) ?? true);
    if (tuto) {
      Timer(Duration(microseconds: 0), () {
        intro.start(context);
      });
      StorageManager.sharedPreferences.setBool(bookingtuto, false);
    }
    super.initState();
  }

  @override
  void dispose() {
    Timer(Duration(microseconds: 0), () {
      intro.dispose();
    });
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _textStyle = Theme.of(context).textTheme.bodyText2;
    super.didChangeDependencies();
  }

  Future _initGameList() {
    return MoonBlinkRepository.getGameList(widget.partnerId).then((value) {
      if (value is BookingPartnerGameList) {
        setState(() {
          this._data = value;
        });
      }
    });
  }

  Future _initUserWallet() {
    return MoonBlinkRepository.fetchOwnProfile().then((value) {
      setState(() {
        this._wallet = value.wallet;
      });
    });
  }

  _initData() async {
    List<Future> futures = [_initGameList(), _initUserWallet()];
    _isPageLoading = true;
    try {
      await Future.wait(futures, eagerError: true);
      if (_data != null) {
        _add();
        _data.bookingPartnerGameList.forEach((element) {
          _gameNameList.add(CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _selectedGameName = '${element.name}';
                _selectedGameMode = '';
                _switchGameMode(_data.bookingPartnerGameList.indexOf(element));
              });
              Navigator.pop(context);
            },
            child: Text(
              '${element.name}',
              style: _textStyle,
            ),
          ));
        });
      }
    } catch (e) {
      print(e);
      error = e;
      _isPageError = true;
    }
    setState(() {
      _isPageLoading = false;
    });
  }

  void _add() {
    _matchSubject.first.then((value) {
      _matchSubject.add(++value);
      _calculateTotalPrice();
    }, onError: (err) => print(err));
  }

  void _minus() {
    _matchSubject.first.then((value) {
      if (value >= 2) {
        _matchSubject.add(--value);
        _calculateTotalPrice();
      }
    }, onError: (err) => print(err));
  }

  void _calculateTotalPrice() {
    _matchSubject.first.then((value) {
      _totalPriceSubject.add(value * _price);
    }, onError: (err) => print(err));
  }

  _switchGameMode(int index) {
    _resetGameMode();
    _data.bookingPartnerGameList[index].gameModeList.forEach((element) {
      _gameModeList.add(CupertinoActionSheetAction(
        onPressed: () {
          setState(() {
            _selectedGameMode = '${element.gameMode}';
            _price = element.bookingPrice;
            _gameTypeId = element.gameTypeId;
            _calculateTotalPrice();
          });
          Navigator.pop(context);
        },
        child: Text(
          '${element.gameMode}',
          style: _textStyle,
        ),
      ));
    });
  }

  _resetGameMode() {
    _gameModeList.clear();
    _resetPriceAndMatch();
  }

  _resetPriceAndMatch() {
    _totalPriceSubject.add(0);
    _matchSubject.add(1);
  }

  _onTapConfirm() {
    int partnerId = widget.partnerId;
    _totalPriceSubject.first.then((value) {
      if (value != 0) {
        if (_wallet.value < value) return _showNotEnoughCoin();
        setState(() {
          _isConfirmLoading = true;
        });
        _matchSubject.first.then((value) {
          MoonBlinkRepository.booking(partnerId, _gameTypeId, value).then(
              (value) => {
                    Navigator.pushReplacementNamed(context, RouteName.chatBox,
                        arguments: partnerId),
                    setState(() {
                      _isConfirmLoading = false;
                    })
                  },
              onError: (err) => {
                    showToast(err.toString()),
                    setState(() {
                      _isConfirmLoading = false;
                    })
                  });
        });
      } else {
        showToast(G.of(context).toastnogame);
      }
    });
  }

  _showNotEnoughCoin() {
    showToast('Not Enough Coin');
    // showCupertinoDialog(
    //     context: context,
    //     builder: (context) => CupertinoAlertDialog(
    //           title: Text(G.of(context).notenoughcoin),

    //           ///later change booking to something meaningful
    //           actions: <Widget>[
    //             CupertinoButton(
    //               onPressed: () => Navigator.pop(context),
    //               child: Text(G.of(context).cancel),
    //             ),
    //             CupertinoButton(
    //                 onPressed: () {
    //                   Navigator.pop(context);
    //                   CustomBottomSheet.showTopUpBottomSheet(
    //                           buildContext: context)
    //                       .whenComplete(() => Future.wait([_initUserWallet()]));
    //                 },
    //                 child: Text(G.of(context).topup))
    //           ],
    //         ));
  }

  _showGameNameSheet(BuildContext context) {
    if (_gameNameList.isEmpty) return;
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(G.of(context).selectgame),
            // message: Text('Message'),
            actions: _gameNameList,
            cancelButton: CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: Text(G.of(context).cancel),
            ),
          );
        });
  }

  _showGameModeSheet(BuildContext context) {
    if (_gameModeList.isEmpty) return;
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(G.of(context).selectgameMode),
            // message: Text('Message'),
            actions: _gameModeList,
            cancelButton: CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: Text(G.of(context).cancel),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: SvgPicture.asset(
                back,
                semanticsLabel: 'back',
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).accentColor
                    : Colors.white,
                width: 30,
                height: 30,
              ),
              onPressed: () => Navigator.pop(context)),
          backgroundColor: Colors.black,
          title: Text(G.of(context).confirmbooking),

          // elevation: 15,
          // shadowColor: Colors.blue,
          bottom: PreferredSize(
              child: Container(
                height: 10,
                color: Theme.of(context).accentColor,
              ),
              preferredSize: null),
        ),
        backgroundColor: Colors.grey[200],
        body: Column(
          children: [
            //Top Partner Information
            // Padding(
            //   padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
            //   child: Container(
            //     height: 100,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(15),
            //       color: Theme.of(context).cardColor,
            //       // border:
            //       //     Border.all(color: Colors.black, style: BorderStyle.none),
            //     ),
            //     child:
            Padding(
              padding: EdgeInsets.fromLTRB(2, 10, 2, 20),
              child: Card(
                child: ListTile(
                  leading: CachedNetworkImage(
                    width: 50,
                    height: 50,
                    imageUrl: widget.partnerProfile,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      backgroundImage: imageProvider,
                    ),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CachedLoader(
                      containerHeight: 50,
                      containerWidth: 50,
                    ),
                    errorWidget: (context, url, error) => CachedError(),
                  ),
                  title: Text(
                    widget.partnerName,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  subtitle: Text(
                    widget.partnerBios,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  isThreeLine: true,
                ),
              ),
            ),

            Column(
              children: [
                ///[Game]
                Card(
                  child: ListTile(
                    key: intro.keys[0],
                    // leading: Text('Choose Game'),
                    title: Text(
                      G.of(context).selectgame,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    subtitle: Text(
                      _selectedGameName,
                      style: Theme.of(context).textTheme.caption,
                    ),
                    trailing: _isPageLoading
                        ? CupertinoActivityIndicator()
                        : Icon(Icons.chevron_right),
                    onTap: () {
                      _showGameNameSheet(context);
                    },
                    // isThreeLine: true,
                  ),
                ),

                ///[Game's Mode]
                Card(
                  child: ListTile(
                    key: intro.keys[1],
                    // leading: Text('Choose Game'),
                    title: Text(
                      G.of(context).selectgameMode,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    subtitle: Text(
                      _selectedGameMode,
                      style: Theme.of(context).textTheme.caption,
                    ),
                    trailing: _isPageLoading
                        ? CupertinoActivityIndicator()
                        : Icon(Icons.chevron_right),
                    onTap: () {
                      _showGameModeSheet(context);
                    },
                    // isThreeLine: true,
                  ),
                ),

                ///[Match Count]
                Card(
                  child: Container(
                    key: intro.keys[2],
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            G.of(context).match,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                        _isPageLoading
                            ? Container(
                                margin: const EdgeInsets.only(right: 15),
                                child: CupertinoActivityIndicator())
                            : Padding(
                                padding: EdgeInsets.all(5),
                                child: Container(
                                  //width: 100,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.black),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: _minus,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Icon(Icons.remove),
                                          ),
                                        ),
                                        Container(
                                          height: 100,
                                          width: 1,
                                          color: Colors.black,
                                        ),
                                        StreamBuilder<int>(
                                          stream: _matchSubject.stream,
                                          builder: (context, snapshot) {
                                            //return Text(_matchNumber.toString());
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Text('${snapshot.data}'),
                                            );
                                          },
                                        ),
                                        Container(
                                          height: 100,
                                          width: 1,
                                          color: Colors.black,
                                        ),
                                        InkWell(
                                          onTap: _add,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Icon(Icons.add),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                ),

                Card(
                  child: Container(
                    key: intro.keys[3],
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Image.asset(
                              ImageHelper.wrapAssetsLogo('appbar.jpg'),
                              height: 50,
                              width: 100,
                              fit: BoxFit.contain,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.black
                                  : Colors.black,
                              colorBlendMode: BlendMode.srcIn,
                            )),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  G.of(context).totalprice,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                StreamBuilder<int>(
                                  initialData: 0,
                                  stream: _totalPriceSubject.stream,
                                  builder: (context, snapshot) {
                                    return Text(
                                      '${snapshot.data} ${snapshot.data > 1 ? 'coins' : 'coin'}',
                                      style:
                                          Theme.of(context).textTheme.subtitle2,
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        bottomNavigationBar: Container(
          key: intro.keys[4],
          width: MediaQuery.of(context).size.width,
          height: 68,
          decoration: BoxDecoration(
              color: Theme.of(context).bottomAppBarColor,
              border: Border(top: BorderSide(width: 2, color: Colors.black))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _isPageError
                ? Center(child: Text('$error'))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: _wallet == null
                              ? CupertinoActivityIndicator()
                              : Text(
                                  'You have ${_wallet.value} ${_wallet.value <= 1 ? 'coin' : 'coins'}.',
                                  style:
                                      Theme.of(context).textTheme.subtitle1)),
                      // MBButtonWidget(
                      //   onTap: null,
                      //   title: 'Button',
                      // )
                      // Container(child: Text('1000 Coins')),
                      _isPageLoading
                          ? CupertinoActivityIndicator()
                          : InkWell(
                              onTap: _onTapConfirm,
                              child: Container(
                                key: intro.keys[5],
                                child: _isConfirmLoading
                                    ? CupertinoActivityIndicator()
                                    : Center(
                                        child: Text(
                                          G.of(context).confirm,
                                          style: Theme.of(context)
                                              .accentTextTheme
                                              .button,
                                        ),
                                      ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Theme.of(context).accentColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black
                                          : Colors.black,
                                      spreadRadius: 2,
                                      // blurRadius: 2,
                                      offset: Offset(
                                          -8, 7), // changes position of shadow
                                    ),
                                  ],
                                ),
                                width: 100,
                                height: 45,
                              ),
                            ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
