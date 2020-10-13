import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/game_profile.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';

class GameModeBottomSheet extends StatefulWidget {
  final List<GameMode> gameModeList;
  final List<Map<String, int>> selectedGameModeIndex;
  final Function(List<Map<String, int>> newSelectedGameModeIndex) onDone;

  const GameModeBottomSheet(
      {Key key,
      @required this.gameModeList,
      this.onDone,
      this.selectedGameModeIndex})
      : super(key: key);

  @override
  _GameModeBottomSheet createState() => _GameModeBottomSheet();
}

class _GameModeBottomSheet extends State<GameModeBottomSheet> {
  TextStyle _textStyle;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textStyle = TextStyle(color: Theme.of(context).accentColor);
  }

  _buildCharge() {
    int type = StorageManager.sharedPreferences.getInt(mUserType);
    final TapGestureRecognizer _learnMore = TapGestureRecognizer();
    _learnMore.onTap = () {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              content: Text('Learn More'),
              actions: [
                CupertinoButton(
                  child: Text('Okay'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            );
          });
    };

    switch (type) {
      case 1:
        return Text.rich(
          TextSpan(
            text: G.current.chargeForNormalPartner,
            style: TextStyle(fontWeight: FontWeight.bold),
            // children: [
            //   TextSpan(
            //       text: 'Learn more',
            //       recognizer: _learnMore,
            //       style: TextStyle(color: Theme.of(context).accentColor)),
            // ]
          ),
          textAlign: TextAlign.center,
        );
        break;
      case 2:
        return Text.rich(
          TextSpan(
            text: G.current.chargeForCeleNStreamer,
            style: TextStyle(fontWeight: FontWeight.bold),
            // children: [
            //   TextSpan(
            //       text: 'Learn more',
            //       recognizer: _learnMore,
            //       style: TextStyle(color: Theme.of(context).accentColor)),
            // ]
          ),
          textAlign: TextAlign.center,
        );
        break;
      case 3:
        return Text.rich(
          TextSpan(
            text: G.current.chargeForCeleNStreamer,
            style: TextStyle(fontWeight: FontWeight.bold),
            // children: [
            //   TextSpan(
            //       text: 'Learn more',
            //       recognizer: _learnMore,
            //       style: TextStyle(color: Theme.of(context).accentColor)),
            // ]
          ),
          textAlign: TextAlign.center,
        );
        break;
      case 4:
        return Text.rich(
          TextSpan(
            text: G.current.chargeForPro,
            style: TextStyle(fontWeight: FontWeight.bold),
            // children: [
            //   TextSpan(
            //       text: 'Learn more',
            //       recognizer: _learnMore,
            //       style: TextStyle(color: Theme.of(context).accentColor)),
            // ]
          ),
          textAlign: TextAlign.center,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(G.of(context).cancel, style: _textStyle),
              ),
              Text(G.current.selectgameMode,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              CupertinoButton(
                onPressed: () {
                  widget.selectedGameModeIndex.sort((a, b) =>
                      int.tryParse(a.keys.first) > int.tryParse(b.keys.first)
                          ? 1
                          : 0);
                  widget.onDone(widget.selectedGameModeIndex);
                  Navigator.pop(context);
                },
                child: Text(G.current.done, style: _textStyle),
              ),
            ],
          ),
        ),
        _buildCharge(),
        SizedBox(height: 10.0),
        Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: widget.gameModeList.length,
            itemBuilder: (context, index) {
              return GameModeListTile(
                  widget.gameModeList, widget.selectedGameModeIndex, index);
            },
          ),
        )
      ],
    );
  }
}

class GameModeListTile extends StatefulWidget {
  final List<GameMode> gameModeList;
  final List<Map<String, int>> selectedGameModeIndex;
  final int index;

  const GameModeListTile(
      this.gameModeList, this.selectedGameModeIndex, this.index,
      {Key key})
      : super(key: key);

  @override
  _GameModeListTileState createState() => _GameModeListTileState();
}

class _GameModeListTileState extends State<GameModeListTile> {
  TextEditingController _gamePriceController;
  int _defaultPrice = 0;

  @override
  void initState() {
    _gamePriceController = TextEditingController(
        text: '${widget.gameModeList[widget.index].price}');
    GameMode item = widget.gameModeList[widget.index];
    widget.selectedGameModeIndex.forEach((element) {
      if (element.containsKey(item.id.toString())) {
        _gamePriceController.text = element.values.first.toString();
        return;
      }
    });
    _defaultPrice = widget.gameModeList[widget.index].defaultPrice;
    super.initState();
  }

  _showMaterialDialog(BuildContext context, TextEditingController controller) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter price for a game', textAlign: TextAlign.center),
            content: CupertinoTextField(
              decoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  GameMode item = widget.gameModeList[widget.index];
                  widget.selectedGameModeIndex.forEach((element) {
                    if (element.containsKey(item.id.toString())) {
                      _gamePriceController.text =
                          element.values.first.toString();
                      return;
                    }
                  });
                },
                child: Text(G.of(context).cancel),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    GameMode item = widget.gameModeList[widget.index];
                    widget.selectedGameModeIndex.forEach((element) {
                      if (element.containsKey(item.id.toString())) {
                        int price = int.tryParse(controller.text);
                        if (price >= _defaultPrice) {
                          element[item.id.toString()] =
                              int.tryParse(controller.text);
                        } else {
                          controller.text = item.price.toString();
                          element[item.id.toString()] = item.price;
                          showToast(
                              "Can't update price. It's lower than the default");
                        }
                        return;
                      }
                    });
                  });
                },
                child: Text(G.of(context).submit),
              )
            ],
          );
        });
  }

  _showCupertinoDialog(BuildContext context, TextEditingController controller) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Enter price for a game', textAlign: TextAlign.center),
            content: CupertinoTextField(
              decoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                  GameMode item = widget.gameModeList[widget.index];
                  widget.selectedGameModeIndex.forEach((element) {
                    if (element.containsKey(item.id.toString())) {
                      _gamePriceController.text =
                          element.values.first.toString();
                      return;
                    }
                  });
                },
                child: Text(G.of(context).cancel),
              ),
              CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    GameMode item = widget.gameModeList[widget.index];
                    widget.selectedGameModeIndex.forEach((element) {
                      if (element.containsKey(item.id.toString())) {
                        int price = int.tryParse(controller.text);
                        if (price >= _defaultPrice) {
                          element[item.id.toString()] =
                              int.tryParse(controller.text);
                        } else {
                          controller.text = item.price.toString();
                          element[item.id.toString()] = item.price;
                          showToast(
                              "Can't update price. it's lower than the default");
                        }
                        return;
                      }
                    });
                  });
                },
                child: Text(G.of(context).submit),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    GameMode item = widget.gameModeList[widget.index];
    bool isSelected = false;
    widget.selectedGameModeIndex.forEach((element) {
      if (int.tryParse(element.keys.first) == item.id) {
        isSelected = true;
        return;
      }
    });
    return Card(
      elevation: 0.3,
      child: ListTile(
        title: Text(item.mode),
        subtitle: Row(
          children: [
            Text('Price - ${_gamePriceController.text} Coins'),
            SizedBox(width: 10),
            if (StorageManager.sharedPreferences.getInt(mUserType) == 2 ||
                StorageManager.sharedPreferences.getInt(mUserType) == 3 ||
                StorageManager.sharedPreferences.getInt(mUserType) == 4)
              InkWell(onTap: () => _onTapEditPrice(), child: Icon(Icons.edit))
          ],
        ),
        onTap: () => _onTapGameModeListTile(
            item.id, int.tryParse(_gamePriceController.text), isSelected),
        trailing: Icon(
          Icons.check,
          color:
              isSelected ? Theme.of(context).accentColor : Colors.transparent,
        ),
        selected: isSelected,
      ),
    );
  }

  _onTapGameModeListTile(int id, int price, bool isSelected) {
    if (isSelected) {
      int selIndex = 0;
      setState(() {
        widget.selectedGameModeIndex.forEach((element) {
          if (int.tryParse(element.keys.first) == id) {
            selIndex = widget.selectedGameModeIndex.indexOf(element);
            return;
          }
        });
        widget.selectedGameModeIndex.removeAt(selIndex);
      });
    } else {
      setState(() {
        widget.selectedGameModeIndex.add({id.toString(): price});
      });
    }
  }

  _onTapEditPrice() {
    if (Platform.isAndroid) {
      _showMaterialDialog(context, _gamePriceController);
    } else if (Platform.isIOS) {
      _showCupertinoDialog(context, _gamePriceController);
    } else {
      showToast(G.of(context).toastplatformnotsupport);
    }
  }
}
