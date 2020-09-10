import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/MoonBlink_Box_widget.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:oktoast/oktoast.dart';

class BookingPage extends StatefulWidget {
  BookingPage({Key key, this.partnerUser}) : super(key: key);
  final PartnerUser partnerUser;
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String _gameName = '';
  String _gameMode = '';
  int _matchNumber = 1;
  void add() {
    setState(() {
      _matchNumber++;
    });
  }

  void minus() {
    setState(() {
      if (_matchNumber != 1) _matchNumber--;
    });
  }

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() {
    print('Init Later');
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyle = Theme.of(context).textTheme.bodyText2;
    List<Widget> _gameModeSheet = [
      CupertinoActionSheetAction(
        onPressed: () {
          setState(() {
            _gameMode = 'Classic';
          });
          Navigator.pop(context);
        },
        child: Text(
          'Classic',
          style: _textStyle,
        ),
      ),
      CupertinoActionSheetAction(
        onPressed: () {
          setState(() {
            _gameMode = 'Rank';
          });
          Navigator.pop(context);
        },
        child: Text(
          'Rank',
          style: _textStyle,
        ),
      ),
      CupertinoActionSheetAction(
        onPressed: () {
          setState(() {
            _gameMode = 'Arcade';
          });
          Navigator.pop(context);
        },
        child: Text(
          'Arcade',
          style: _textStyle,
        ),
      ),
      // CupertinoActionSheetAction(
      //   onPressed: () {
      //     setState(() {
      //       _gameName = 'CounterStrike-GO';
      //     });
      //     Navigator.pop(context);
      //   },
      //   child: Text(
      //     'CounterStrike-GO',
      //     style: _textStyle,
      //   ),
      // ),
    ];
    //TODO:
    List<Widget> _cupertinoActionSheet = [
      CupertinoActionSheetAction(
        onPressed: () {
          setState(() {
            _gameName = 'Mobile Legends';
          });
          Navigator.pop(context);
        },
        child: Text(
          'Mobile Legends',
          style: _textStyle,
        ),
      ),
      CupertinoActionSheetAction(
        onPressed: () {
          setState(() {
            _gameName = 'PUBG-Mobile';
          });
          Navigator.pop(context);
        },
        child: Text(
          'PUBG-Mobile',
          style: _textStyle,
        ),
      ),
      CupertinoActionSheetAction(
        onPressed: () {
          setState(() {
            _gameName = 'DOTA2';
          });
          Navigator.pop(context);
        },
        child: Text(
          'DOTA2',
          style: _textStyle,
        ),
      ),
      CupertinoActionSheetAction(
        onPressed: () {
          setState(() {
            _gameName = 'CounterStrike-GO';
          });
          Navigator.pop(context);
        },
        child: Text(
          'CounterStrike-GO',
          style: _textStyle,
        ),
      ),
    ];
    _showGameNameSheet(BuildContext context) {
      showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
              title: Text('Select Game'),
              // message: Text('Message'),
              actions: _cupertinoActionSheet,
              cancelButton: CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            );
          });
    }

    _showGameModeSheet(BuildContext context) {
      showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
              title: Text('Select Game Mode'),
              // message: Text('Message'),
              actions: _gameModeSheet,
              cancelButton: CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            );
          });
    }

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
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(2, 10, 2, 20),
              child: Card(
                child: ListTile(
                  leading: CachedNetworkImage(
                    imageUrl:
                        widget.partnerUser.prfoileFromPartner.profileImage,
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
                    'Choose Games',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  subtitle: Text(
                    _gameName,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  trailing: Icon(Icons.chevron_right),
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
                    _gameMode,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  trailing: Icon(Icons.chevron_right),
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
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                            borderRadius: BorderRadius.circular(20)),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: minus,
                                child: Icon(Icons.remove),
                              ),
                              Container(
                                height: 100,
                                width: 1,
                                color: Colors.black,
                              ),
                              Text(_matchNumber.toString()),
                              Container(
                                height: 100,
                                width: 1,
                                color: Colors.black,
                              ),
                              GestureDetector(
                                onTap: add,
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
                          color: Theme.of(context).brightness == Brightness.dark
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
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Text(
                              '1000 Coins',
                              style: Theme.of(context).textTheme.subtitle2,
                            )
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
                child: Text(
              'Total Price: 1000 Coins',
              style: Theme.of(context).textTheme.subtitle1,
            )),
            // MBButtonWidget(
            //   onTap: null,
            //   title: 'Button',
            // )
            // Container(child: Text('1000 Coins')),
            SizedBox(
              width: 40,
            ),
            Container(
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
            )
          ],
        ),
      ),
    );
  }
}
