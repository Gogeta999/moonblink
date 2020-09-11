import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/booking_partner_game_list.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

class BookingPage extends StatefulWidget {
  BookingPage({Key key, this.partnerUser}) : super(key: key);
  final PartnerUser partnerUser;
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int _price = 0;
  List<Widget> _gameNameList = [];
  List<Widget> _gameModeList = [];
  BookingPartnerGameList _data;
  String _selectedGameName = '';
  String _selectedGameMode = '';

  TextStyle _textStyle;
  bool _isPageLoading = false;
  bool _isPageError = false;

  BehaviorSubject<int> _matchSubject = BehaviorSubject.seeded(0);
  BehaviorSubject<int> _totalPriceSubject = BehaviorSubject.seeded(0);

  ///send back to server
  int _gameTypeId = 0;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _textStyle = Theme.of(context).textTheme.bodyText2;
    super.didChangeDependencies();
  }

  _initData() async {
    _isPageLoading = true;
    BookingPartnerGameList data;
    try {
      data =
          await MoonBlinkRepository.getGameList(widget.partnerUser.partnerId);
      _add();
      data.bookingPartnerGameList.forEach((element) {
        _gameNameList.add(CupertinoActionSheetAction(
          onPressed: () {
            setState(() {
              _selectedGameName = '${element.name}';
              _selectedGameMode = '';
              _switchGameMode(data.bookingPartnerGameList.indexOf(element));
            });
            Navigator.pop(context);
          },
          child: Text(
            '${element.name}',
            style: _textStyle,
          ),
        ));
      });
    } catch (e) {
      print(e);
      setState(() {
        _isPageError = true;
      });
    }
    setState(() {
      this._data = data;
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
    int partnerId = widget.partnerUser.partnerId;
    _totalPriceSubject.first.then((value) {
      if (value != 0)
        _matchSubject.first.then((value) {
          MoonBlinkRepository.booking(partnerId, _gameTypeId, value).then(
              (value) => Navigator.pushNamed(context, RouteName.chatBox,
                  arguments: partnerId), onError: (err) => showToast(err.toString()));
        });
    });
  }

  _showGameNameSheet(BuildContext context) {
    if (_gameNameList.isEmpty) return;
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text('Select Game'),
            // message: Text('Message'),
            actions: _gameNameList,
            cancelButton: CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
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
            title: Text('Select Game Mode'),
            // message: Text('Message'),
            actions: _gameModeList,
            cancelButton: CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Confirm Your Booking'),
        leading: IconButton(
            icon: Icon(CupertinoIcons.back),
            onPressed: () {
              Navigator.pop(context);
            }),
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
      body: _isPageError
          ? Center(
              child: Text('Something went wrong!',
                  style: Theme.of(context).textTheme.bodyText1))
          : Column(
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
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(2, 10, 2, 20),
                    child: Card(
                      child: ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: widget
                              .partnerUser.prfoileFromPartner.profileImage,
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
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
                          widget.partnerUser.partnerName,
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                        subtitle: Text(
                          widget.partnerUser.prfoileFromPartner.bios,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        isThreeLine: true,
                      ),
                    ),
                  ),
                ),

                Column(
                  children: [
                    ///[Game]
                    Card(
                      elevation: 8,
                      child: ListTile(
                        // leading: Text('Choose Game'),
                        title: Text(
                          'Choose Game',
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
                        // leading: Text('Choose Game'),
                        title: Text(
                          'Choose Mode',
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
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                'Match',
                                style: Theme.of(context).textTheme.subtitle1,
                              )),
                          _isPageLoading
                              ? Container(
                                  margin: const EdgeInsets.only(right: 15),
                                  child: CupertinoActivityIndicator())
                              : Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: _minus,
                                            child: Icon(Icons.remove),
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
                                                return Text('${snapshot.data}');
                                              }),
                                          Container(
                                            height: 100,
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                          GestureDetector(
                                            onTap: _add,
                                            child: Icon(Icons.add),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                        ],
                      ),
                    )),

                    Card(
                        child: Container(
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
                                    'Total Price',
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                  StreamBuilder<int>(
                                      initialData: 0,
                                      stream: _totalPriceSubject.stream,
                                      builder: (context, snapshot) {
                                        return Text(
                                          '${snapshot.data} ${snapshot.data > 1 ? 'coins' : 'coin'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2,
                                        );
                                      })
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
                  ],
                )
              ],
            ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 68,
        decoration: BoxDecoration(
            color: Theme.of(context).bottomAppBarColor,
            border: Border(top: BorderSide(width: 2, color: Colors.black))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                child: StreamBuilder<int>(
                    initialData: 0,
                    stream: _totalPriceSubject.stream,
                    builder: (context, snapshot) {
                      return Text(
                        'Total Price: ${snapshot.data} ${snapshot.data > 1 ? 'coins' : 'coin'}',
                        style: Theme.of(context).textTheme.subtitle1,
                      );
                    })),
            // MBButtonWidget(
            //   onTap: null,
            //   title: 'Button',
            // )
            // Container(child: Text('1000 Coins')),
            SizedBox(
              width: 40,
            ),
            InkWell(
              onTap: _onTapConfirm,
              child: Container(
                child: Center(
                  child: Text(
                    'Confirm',
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Theme.of(context).accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.black,
                        spreadRadius: 2,
                        // blurRadius: 2,
                        offset: Offset(-8, 7), // changes position of shadow
                      ),
                    ]),
                width: 100,
                height: 45,
              ),
            )
          ],
        ),
      ),
    );
  }
}
