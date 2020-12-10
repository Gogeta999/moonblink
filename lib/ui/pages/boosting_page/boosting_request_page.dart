import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/UserBoostingGamePrice.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:oktoast/oktoast.dart';

class BoostingRequestPage extends StatefulWidget {
  final int partnerId;
  final String partnerName;
  final String partnerProfile;
  final String partnerBios;
  final List<BoostableGame> boostableGameList;
  BoostingRequestPage(
      {Key key,
      this.partnerId,
      this.partnerName,
      this.partnerProfile,
      this.partnerBios,
      this.boostableGameList})
      : super(key: key);

  @override
  _BoostingRequestPageState createState() => _BoostingRequestPageState();
}

class _BoostingRequestPageState extends State<BoostingRequestPage> {
  ///UI
  TextStyle _textStyle;
  var error;
  bool _isPageLoading = true;
  bool _isPageError = false;
  bool _isConfirmLoading = false;

  ///UI

  ///Bottom Sheet
  List<Widget> _boostingGameNames = [];
  List<Widget> _gameRankFrom = [];
  List<Widget> _gameUpToRank = [];

  ///Bottom Sheet

  ///Remote Data
  //List<BoostableGame> _boostingGames = [];
  List<UserBoostingGamePrice> _userBoostingGamePrice = [];
  Wallet _wallet = Wallet(value: 0);

  ///Remote Data

  ///Data to send back
  int _selectedGameId = -1;
  String _selectedGameName = '';
  int _selectedRankFromIndex = -1; //for validation
  String _selectedRankFrom = '???';
  int _selectedUpToRankIndex = 100000; //for validation
  String _selectedUpToRank = '???';
  int _estimateFinishedDays = 0;
  int _estimateFinishedHours = 0;
  int _totalPrice = 0;
  String _boostingUpTo = '';
  //int _boostingUpToIndex = 0;

  ///Data to send back

  //final _priceController = TextEditingController();
  //final _descriptionController = TextEditingController();

  void _initData() {
    Future.wait([_initUserWallet(), _initBoostingGamePrice()], eagerError: true)
        .then((value) {
      setState(() {
        _isPageLoading = false;
      });
    });
  }

  Future<void> _initUserWallet() async {
    MoonBlinkRepository.getUserWallet().then((value) {
      setState(() {
        this._wallet = value;
      });
    }, onError: (e) {
      setState(() {
        this.error = e;
        _isPageError = true;
      });
    });
  }

  Future<void> _initBoostingGamePrice() async {
    MoonBlinkRepository.getBoostingGameList(widget.partnerId).then((value) {
      setState(() {
        this._userBoostingGamePrice = value;
      });
      _userBoostingGamePrice.forEach((element) {
        _boostingGameNames.add(CupertinoActionSheetAction(
          child: Text(element.name, style: _textStyle),
          onPressed: () {
            setState(() {
              _addGameRankFrom(element);
              // for (int i = 0; i < element.boostOrderPrice.length; ++i) {
              //   _gameRankFrom.add(CupertinoActionSheetAction(
              //     onPressed: () {
              //       if (this._selectedUpToRankIndex > i) {
              //         setState(() {
              //           this._selectedRankFromIndex = i;
              //           this._selectedRankFrom = element.levels[i];
              //         });
              //         _calculateTotalPriceAndDuration();
              //       } else {
              //         showToast('Current rank should be lower than To Rank');
              //       }
              //       Navigator.pop(context);
              //     },
              //     child: Text(element.levels[i],
              //         style: Theme.of(context).textTheme.button),
              //   ));

              //   _gameUpToRank.add(CupertinoActionSheetAction(
              //     onPressed: () {
              //       if (this._selectedRankFromIndex < i) {
              //         setState(() {
              //           this._selectedUpToRankIndex = i;
              //           this._selectedUpToRank = element.levels[i];
              //         });
              //         _calculateTotalPriceAndDuration();
              //       } else {
              //         showToast('Current rank should be lower than To Rank');
              //       }
              //       Navigator.pop(context);
              //     },
              //     child: Text(element.levels[i],
              //         style: Theme.of(context).textTheme.button),
              //   ));
              // }
              Navigator.pop(context);
            });
          },
        ));
      });
    }, onError: (e) {
      setState(() {
        this.error = e;
        _isPageError = true;
      });
    });
  }

  void _addGameRankFrom(UserBoostingGamePrice element) {
    //_boostingUpTo = element.boostOrderPrice.last.upToRank;
    //_boostingUpToIndex = element.levels.indexOf(_boostingUpTo);
    _selectedGameName = element.name;
    _selectedGameId = element.id;
    _gameRankFrom.clear();
    _gameUpToRank.clear();
    _selectedRankFromIndex = -1; //for validation
    _selectedRankFrom = '???';
    _selectedUpToRankIndex = 100000; //for validation
    _selectedUpToRank = '???';
    _totalPrice = 0;
    _estimateFinishedDays = 0;
    _estimateFinishedHours = 0;
    element.boostOrderPrice.asMap().forEach((i, e) {
      if (e.isAccept == 1) {
        _gameRankFrom.add(CupertinoActionSheetAction(
          onPressed: () {
            setState(() {
              this._selectedRankFromIndex = i;
              this._selectedRankFrom = element.levels[i];
              this._selectedUpToRankIndex = 100000;
              this._selectedUpToRank = '???';
              _totalPrice = 0;
              _estimateFinishedDays = 0;
              _estimateFinishedHours = 0;
            });
            _addGameRankTo(element);
            //_calculateTotalPriceAndDuration();
            Navigator.pop(context);
          },
          child: Text(element.levels[i],
              style: Theme.of(context).textTheme.button),
        ));
      }
    });
  }

  void _addGameRankTo(UserBoostingGamePrice element) {
    _gameUpToRank.clear();
    for (int i = _selectedRankFromIndex;
        i < element.boostOrderPrice.length;
        ++i) {
      if (element.boostOrderPrice[i].isAccept == 1) {
        _gameUpToRank.add(CupertinoActionSheetAction(
          onPressed: () {
            if (this._selectedRankFromIndex < i + 1) {
              setState(() {
                this._selectedUpToRankIndex = i + 1;
                this._selectedUpToRank = element.levels[i + 1];
              });
              _calculateTotalPriceAndDuration();
            } else {
              showToast(G.current.boostReverseRankToastError);
            }
            Navigator.pop(context);
          },
          child: Text(element.levels[i + 1],
              style: Theme.of(context).textTheme.button),
        ));
      } else {
        break;
      }
    }
  }

  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  void dispose() {
    //_priceController.dispose();
    //_descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _textStyle = Theme.of(context).textTheme.bodyText2;
    super.didChangeDependencies();
  }

  _calculateTotalPriceAndDuration() {
    if (_selectedRankFromIndex == -1 || _selectedUpToRankIndex == 100000) {
      return;
    } else {
      _userBoostingGamePrice.forEach((element) {
        if (element.id == _selectedGameId) {
          int tempPrice = 0;
          int tempDay = 0;
          int tempHour = 0;
          element.boostOrderPrice.forEach((e) {
            if (_selectedRankFromIndex <= element.levels.indexOf(e.rankFrom) &&
                _selectedUpToRankIndex >= element.levels.indexOf(e.upToRank)) {
              tempPrice += e.estimateCost;
              tempDay += e.estimateDay;
              tempHour += e.estimateHour;
            }
          });
          if (tempHour > 23) {
            tempDay += tempHour ~/ 24;
            tempHour %= 24;
          }
          setState(() {
            this._totalPrice = tempPrice;
            this._estimateFinishedDays = tempDay;
            this._estimateFinishedHours = tempHour;
          });
        }
      });
    }
  }

  _showNotEnoughCoin() {
    showToast(G.current.boostNoEnoughCoins);
    // showCupertinoDialog(
    //     context: context,
    //     builder: (context) => CupertinoAlertDialog(
    //           title: Text(G.of(context).notenoughcoin),
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
    //                       .whenComplete(() => _initUserWallet());
    //                 },
    //                 child: Text(G.of(context).topup))
    //           ],
    //         ));
  }

  _showRankFrom(BuildContext context) {
    if (_gameRankFrom.isEmpty) {
      showToast(G.current.boostSelectGameFirst);
      return;
    }
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(G.of(context).selectgamerank),
            actions: _gameRankFrom,
            cancelButton: CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: Text(G.of(context).cancel),
            ),
          );
        });
  }

  _showUpToRank(BuildContext context) {
    if (_gameRankFrom.isEmpty) {
      showToast(G.current.boostSelectGameFirst);
      return;
    }
    if (_selectedRankFromIndex == -1) {
      showToast(G.current.boostSelectGameFirst);
      return;
    }
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(G.of(context).selectgamerank),
            actions: _gameUpToRank,
            cancelButton: CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: Text(G.of(context).cancel),
            ),
          );
        });
  }

  _showGameNameSheet(BuildContext context) {
    if (_userBoostingGamePrice.isEmpty) return;
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(G.of(context).selectgame),
            // message: Text('Message'),
            actions: _boostingGameNames,
            cancelButton: CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: Text(G.of(context).cancel),
            ),
          );
        });
  }

  _onTapConfirm() {
    if (_selectedGameName.isEmpty || _selectedGameId == -1) {
      showToast(G.current.boostSelectGameFirst);
      return;
    }
    if (_selectedRankFrom == "???" || _selectedRankFrom.isEmpty) {
      showToast(G.current.boostSelectCurrentRank);
      return;
    }
    if (_selectedUpToRank == "???" || _selectedUpToRank.isEmpty) {
      showToast(G.current.boostSelectUptoRank);
      return;
    }
    if (_wallet.value < _totalPrice) {
      _showNotEnoughCoin();
      return;
    }
    setState(() {
      _isConfirmLoading = true;
    });
    MoonBlinkRepository.requestBoosting(
            widget.partnerId,
            _selectedGameId,
            _selectedRankFrom,
            _selectedUpToRank,
            _estimateFinishedDays,
            _estimateFinishedHours,
            _totalPrice)
        .then((value) {
      setState(() {
        _isConfirmLoading = false;
      });
      Navigator.of(context)
          .pushNamed(RouteName.chatBox, arguments: widget.partnerId);
    }, onError: (e) {
      showToast(e.toString());
      setState(() {
        _isConfirmLoading = false;
      });
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
          title: Text(G.current.boostConfirmBoosting),
          bottom: PreferredSize(
              child: Container(
                height: 10,
                color: Theme.of(context).accentColor,
              ),
              preferredSize: null),
        ),
        backgroundColor: Colors.grey[200],
        body: ListView(
          physics: ClampingScrollPhysics(),
          children: [
            ///Bios
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12.0),
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
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.partnerBios,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      if (_boostingUpTo.isNotEmpty)
                        Text(G.current.boostProvideTo + '$_boostingUpTo'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              ),
            ),

            ///[Game]
            Card(
              child: ListTile(
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
              ),
            ),

            ///[GameRank]
            Card(
                child: Container(
              margin: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    G.current.boostRank,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 5),
                  Text('$_selectedRankFrom  ' +
                      G.current.boostTo +
                      '  $_selectedUpToRank'),
                  SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => _showRankFrom(context),
                        child: Container(
                            width: 70,
                            height: 70,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).accentColor,
                                  width: 1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${_selectedRankFrom == '???' ? "Current\nRank" : _selectedRankFrom.split(" ").join("\n")}',
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            )),
                      ),
                      Icon(Icons.forward_sharp, size: 40),
                      GestureDetector(
                        onTap: () => _showUpToRank(context),
                        child: Container(
                            width: 70,
                            height: 70,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).accentColor,
                                  width: 1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${_selectedUpToRank == '???' ? "To\nRank" : _selectedUpToRank.split(" ").join("\n")}',
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            )),
                      ),
                    ],
                  )
                ],
              ),
            )),

            ///[Duration]
            Card(
              child: ListTile(
                title: Text(
                  G.current.boostEstimateTime,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                subtitle: Text(
                  ('$_estimateFinishedDays ' +
                      G.current.boostDays +
                      ', $_estimateFinishedHours ' +
                      G.current.boostHours),
                  style: Theme.of(context).textTheme.caption,
                ),
                trailing: _isPageLoading
                    ? CupertinoActivityIndicator()
                    : null, //Icon(Icons.chevron_right),
                // onTap: () {
                //   _showDurationPicker();
                // },
              ),
            ),

            ///[Price]
            Card(
              child: ListTile(
                title: Text(
                  G.current.totalprice,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                subtitle: Text(
                  '$_totalPrice ' + G.current.boostCoin,
                  style: Theme.of(context).textTheme.caption,
                ),
                trailing: _isPageLoading
                    ? CupertinoActivityIndicator()
                    : null, //Icon(Icons.chevron_right),
                // onTap: () {
                //   _showEstimatePrice();
                // },
              ),
            ),

            ///[Note]
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  // "Note: Sometime our CoPlayer may need a little more time than your expected finished duration, please try to understand",
                  G.current.boostNote,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
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
                                  G.current.youHave +
                                      ' ${_wallet.value} ${_wallet.value <= 1 ? 'coin' : 'coins'}.',
                                  style:
                                      Theme.of(context).textTheme.subtitle1)),
                      _isPageLoading
                          ? CupertinoActivityIndicator()
                          : InkWell(
                              onTap: _onTapConfirm,
                              child: Container(
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

// _showDurationPicker() {
//   Picker(
//       selecteds: [this._selectedDays, this._selectedHours],
//       backgroundColor: Theme.of(context).backgroundColor,
//       height: MediaQuery.of(context).size.height * 0.3,
//       title: Text('Select'),
//       selectedTextStyle: TextStyle(color: Theme.of(context).accentColor),
//       adapter: PickerDataAdapter<String>(pickerdata: [
//         List.generate(
//             1000, (index) => '$index ${index > 0 ? "days" : "day"}'),
//         List.generate(24, (index) => '$index ${index > 0 ? "hours" : "hour"}')
//       ], isArray: true),
//       delimiter: [
//         PickerDelimiter(
//             child: Container(
//                 width: 30.0,
//                 alignment: Alignment.center,
//                 color: Theme.of(context).backgroundColor,
//                 child: Text(' : ',
//                     style: TextStyle(
//                         color: Theme.of(context).accentColor,
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold))))
//       ],
//       onCancel: () {
//         debugPrint('Cancelling');
//       },
//       onConfirm: (picker, ints) {
//         setState(() {
//           this._selectedDays = ints.first;
//           this._selectedHours = ints.last;
//         });
//       }).showModal(this.context);
// }

// _showEstimatePrice() {
//   if (Platform.isAndroid) {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text("Estimate Price", textAlign: TextAlign.center),
//             content: CupertinoTextField(
//               autofocus: true,
//               decoration:
//                   BoxDecoration(color: Theme.of(context).backgroundColor),
//               controller: _priceController,
//               textAlign: TextAlign.center,
//               keyboardType: TextInputType.number,
//             ),
//             actions: <Widget>[
//               FlatButton(
//                 onPressed: () {
//                   FocusScope.of(context).unfocus();
//                   setState(() {});
//                   Navigator.pop(context);
//                 },
//                 child: Text(G.of(context).submit),
//               )
//             ],
//           );
//         });
//   }

//   if (Platform.isIOS) {
//     showCupertinoDialog(
//         context: context,
//         builder: (context) {
//           return CupertinoAlertDialog(
//             title: Text("Total Price", textAlign: TextAlign.center),
//             content: CupertinoTextField(
//               autofocus: true,
//               decoration:
//                   BoxDecoration(color: Theme.of(context).backgroundColor),
//               controller: _priceController,
//               textAlign: TextAlign.center,
//               keyboardType: TextInputType.number,
//             ),
//             actions: <Widget>[
//               CupertinoButton(
//                 onPressed: () {
//                   FocusScope.of(context).unfocus();
//                   setState(() {});
//                   Navigator.pop(context);
//                 },
//                 child: Text(G.of(context).submit),
//               )
//             ],
//           );
//         });
//   }
// }
