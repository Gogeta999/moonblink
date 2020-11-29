import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:oktoast/oktoast.dart';

class BoostingPage extends StatefulWidget {
  final int partnerId;
  final String partnerName;
  final String partnerProfile;
  final String partnerBios;
  final List<PartnerGameProfile> gameProfiles;
  BoostingPage(
      {Key key,
      this.partnerId,
      this.partnerName,
      this.partnerProfile,
      this.partnerBios,
      this.gameProfiles})
      : super(key: key);

  @override
  _BoostingPageState createState() => _BoostingPageState();
}

class _BoostingPageState extends State<BoostingPage> {
  TextStyle _textStyle;
  var error;
  bool _isPageLoading = true;
  bool _isPageError = false;
  bool _isConfirmLoading = false;
  List<Widget> _boostingGameNames = [];
  List<Widget> _gameRankFrom = [];
  List<Widget> _gameUpToRank = [];
  List<PartnerGameProfile> _boostingGames = [];
  Wallet _wallet = Wallet(value: 0);
  int _selectedGameId = -1;
  String _selectedGameName = '';
  String _selectedRankFrom = 'Select';
  String _selectedUpToRank = 'Select';
  int _selectedDays = 0;
  int _selectedHours = 0;
  String _boostingUpTo = '';
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _initData() {
    _initUserWallet();
    widget.gameProfiles.forEach((element) {
      if (element.boostable == 1) {
        _boostingGames.add(element);
        _boostingGameNames.add(CupertinoActionSheetAction(
          onPressed: () {
            setState(() {
              _boostingUpTo = element.upToRank;
              _selectedGameName = '${element.gameName}';
              _selectedGameId = element.gameId;
              _gameRankFrom.clear();
              _gameUpToRank.clear();
              element.gameRankList.forEach((e) {
                _gameRankFrom.add(CupertinoActionSheetAction(
                  onPressed: () {
                    setState(() {
                      this._selectedRankFrom = e;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(e, style: Theme.of(context).textTheme.button),
                ));
                _gameUpToRank.add(CupertinoActionSheetAction(
                  onPressed: () {
                    setState(() {
                      this._selectedUpToRank = e;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(e, style: Theme.of(context).textTheme.button),
                ));
              });
            });
            Navigator.pop(context);
          },
          child: Text(
            '${element.gameName}',
            style: _textStyle,
          ),
        ));
      }
    });
    if (_boostingGames.isEmpty) {
      setState(() {
        this.error = "This user does not provide Boosting Service";
        this._isPageError = true;
      });
    }
  }

  Future<void> _initUserWallet() async {
    MoonBlinkRepository.getUserWallet().then((value) {
      setState(() {
        this._wallet = value;
        _isPageLoading = false;
      });
    }, onError: (e) {
      setState(() {
        this.error = e;
        _isPageError = true;
      });
    });
  }

  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _textStyle = Theme.of(context).textTheme.bodyText2;
    super.didChangeDependencies();
  }

  _showNotEnoughCoin() {
    showToast('Not Enough Coin');
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

  _showDurationPicker() {
    Picker(
      selecteds: [this._selectedDays, this._selectedHours],
      textStyle: TextStyle(color: Colors.white, fontSize: 20),
      containerColor: Theme.of(context).scaffoldBackgroundColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
        NumberPickerColumn(begin: 0, end: 999, suffix: Text(' Days')),
        NumberPickerColumn(begin: 0, end: 23, suffix: Text(' Hours')),
      ]),
      hideHeader: true,
      confirmText: 'Select',
      cancelTextStyle: TextStyle(fontSize: 16),
      confirmTextStyle:
          TextStyle(color: Theme.of(context).accentColor, fontSize: 16),
      title: Center(child: const Text('Select Estimate duration')),
      selectedTextStyle:
          TextStyle(color: Theme.of(context).accentColor, fontSize: 22),
      onConfirm: (Picker picker, List<int> value) {
        // // You get your duration here
        // Duration _duration = Duration(
        //     hours: picker.getSelectedValues()[0],
        //     minutes: picker.getSelectedValues()[1]);
        setState(() {
          this._selectedDays = value[0];
          this._selectedHours = value[1];
        });
      },
    ).showDialog(context, barrierDismissible: false);
  }

  _showEstimatePrice() {
    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Estimate Price", textAlign: TextAlign.center),
              content: CupertinoTextField(
                autofocus: true,
                decoration:
                    BoxDecoration(color: Theme.of(context).backgroundColor),
                controller: _priceController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  },
                  child: Text(G.of(context).submit),
                )
              ],
            );
          });
    }

    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text("Estimate Price", textAlign: TextAlign.center),
              content: CupertinoTextField(
                autofocus: true,
                decoration:
                    BoxDecoration(color: Theme.of(context).backgroundColor),
                controller: _priceController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
              ),
              actions: <Widget>[
                CupertinoButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  },
                  child: Text(G.of(context).submit),
                )
              ],
            );
          });
    }
  }

  _showRankFrom(BuildContext context) {
    if (_gameRankFrom.isEmpty) {
      showToast('Please select a game first');
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
      showToast('Please select a game first');
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
    if (_boostingGames.isEmpty) return;
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
      showToast('Please select a game');
      return;
    }
    if (_selectedRankFrom == "Select" || _selectedRankFrom.isEmpty) {
      showToast('Please select rank from');
      return;
    }
    if (_selectedUpToRank == "Select" || _selectedUpToRank.isEmpty) {
      showToast('Please select up to rank');
      return;
    }
    final totalHours = (_selectedDays * 24) + _selectedHours;
    if (totalHours <= 0) {
      showToast('Estimate Duration can\'t be blanked');
      return;
    }
    final totalPrice = int.tryParse(_priceController.text) ?? 0;
    if (_wallet.value < totalPrice) {
      _showNotEnoughCoin();
      return;
    }
    setState(() {
      _isConfirmLoading = true;
    });
    MoonBlinkRepository.requestBoosting(widget.partnerId, _selectedGameId,
            _selectedRankFrom, _selectedUpToRank, totalHours, totalPrice)
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
          title: Text("Confirm Boosting"),
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
                        Text('Provide Boosting up to $_boostingUpTo'),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () => _showRankFrom(context),
                    child: Column(
                      children: [
                        Text('Rank From'),
                        SizedBox(height: 5),
                        Text('$_selectedRankFrom',
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 16))
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _showUpToRank(context),
                    child: Column(
                      children: [
                        Text('Up To Rank'),
                        SizedBox(height: 5),
                        Text('$_selectedUpToRank',
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 16))
                      ],
                    ),
                  )
                ],
              ),
            )),

            ///[Duration]
            Card(
              child: ListTile(
                title: Text(
                  "Estimate Duration",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                subtitle: Text(
                  ('$_selectedDays Days, $_selectedHours Hours'),
                  style: Theme.of(context).textTheme.caption,
                ),
                trailing: _isPageLoading
                    ? CupertinoActivityIndicator()
                    : Icon(Icons.chevron_right),
                onTap: () {
                  _showDurationPicker();
                },
              ),
            ),

            ///[Price]
            Card(
              child: ListTile(
                title: Text(
                  "Estimate Price",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                subtitle: Text(
                  '${int.tryParse(_priceController.text) ?? 0} Coins',
                  style: Theme.of(context).textTheme.caption,
                ),
                trailing: _isPageLoading
                    ? CupertinoActivityIndicator()
                    : Icon(Icons.chevron_right),
                onTap: () {
                  _showEstimatePrice();
                },
              ),
            ),

            ///[Description]
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoTextField(
                  decoration: BoxDecoration(color: Colors.transparent),
                  minLines: 3,
                  maxLines: 3,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  style: TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.done,
                  placeholder:
                      "Description your requirement so our CoPlayer can decide they will taking your order or not.",
                ),
              ),
            ),

            ///[Note]
            const Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  "Note: Sometime our CoPlayer may need a little more time than your estimate duraion, please be understand. But if they pass your expected duration more than 3 or 4 days than you can report to our customer service and we will give them punishment",
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
                                  'You have ${_wallet.value} ${_wallet.value <= 1 ? 'coin' : 'coins'}.',
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
