import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/game_profile.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/pages/game_profile/choose_user_play_game_page.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';

enum UpdateOrSubmitButtonState { initial, loading }

class UpdateGameProfilePage extends StatefulWidget {
  final GameProfile gameProfile;

  const UpdateGameProfilePage({Key key, @required this.gameProfile})
      : super(key: key);

  @override
  _UpdateGameProfilePageState createState() => _UpdateGameProfilePageState();
}

class _UpdateGameProfilePageState extends State<UpdateGameProfilePage> {
  ///will send back to server
  TextEditingController _gameIdController = TextEditingController();
  String _level = '';
  String _gameMode = '';
  List<GameMode> _gameModeList = [];
  List<int> _selectedGameModeIndex = [];
  File _skillCoverPhoto;

  ///UI properties
  int count = 0;
  bool _isUILocked = false;
  BehaviorSubject<UpdateOrSubmitButtonState> _submitOrUpdateSubject =
      BehaviorSubject(onCancel: () => print('Cancelling'))
        ..add(UpdateOrSubmitButtonState.initial);
  TextStyle _textStyle;
  List<Widget> _cupertinoActionSheet = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textStyle = Theme.of(context).textTheme.bodyText1;
  }

  @override
  void initState() {
    _initWithRemoteData();
    super.initState();
  }

  @override
  void dispose() {
    //_discardChanges();
    super.dispose();
  }

  _discardChanges() {
    ///original list always got modify...
    // _gameModeList.forEach((e) {
    //   if (_selectedGameModeIndex.contains(e.id)) {
    //     e.selected = 0;
    //   }
    // });
  }

  _initWithRemoteData() {
    _gameModeList = List.unmodifiable(widget.gameProfile.gameModeList);
    _gameIdController.text = widget.gameProfile.playerId;
    _level = widget.gameProfile.level;
    for (int i = 0; i < _gameModeList.length; ++i) {
      if (_gameModeList[i].selected == 1) {
        _selectedGameModeIndex.add(_gameModeList[i].id);
        // _gameMode += _gameModeList[i].mode;
        //
        // if (i >= _selectedGameModeIndex.length - 1)
        //   continue;
        // else
        //   _gameMode += ', ';
      }
    }

    _updateGameMode();

    widget.gameProfile.gameRankList.forEach((element) {
      _cupertinoActionSheet.add(CupertinoActionSheetAction(
          onPressed: () {
            setState(() {
              _level = element;
            });
            Navigator.pop(context);
          },
          child: Text(element, style: _textStyle)));
    });
  }

  _updateGameMode() {
    _gameMode = '';
    for (int i = 0; i < _gameModeList.length; ++i) {
      bool isSelected = _selectedGameModeIndex.contains(_gameModeList[i].id);
      if (isSelected) {
        _gameMode += _gameModeList[i].mode;

        if (i >= _selectedGameModeIndex.length - 1)
          continue;
        else
          _gameMode += ', ';
      }
    }
  }

  _showMaterialDialog(BuildContext context, TextEditingController controller) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter your game ID', textAlign: TextAlign.center),
            content: CupertinoTextField(
              decoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
              controller: controller,
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                child: Text('Submit'),
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
            title: Text('Enter your game ID\n', textAlign: TextAlign.center),
            content: CupertinoTextField(
              decoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
              controller: controller,
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                child: Text('Submit'),
              )
            ],
          );
        });
  }

  _showCupertinoBottomSheet(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text('Select Your Game Rank'),
            actions: _cupertinoActionSheet,
            cancelButton: CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          );
        });
  }

  Card _buildGameProfileCard(
      {String title, String subtitle, IconData iconData, Function onTap}) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 8,
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: Theme.of(context).textTheme.bodyText1),
        subtitle: Text(subtitle),
        trailing: Icon(iconData),
      ),
    );
  }

  Card _buildTitleWidget({String title}) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: <Widget>[
            Text(title,
                style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            Divider(thickness: 2),
          ],
        ),
      ),
    );
  }

  Card _buildGameProfilePhotoCard() {
    return Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 8,
        child: Row(
          children: <Widget>[
            ///for now skill cover image later server will give a sample photo url
            _buildCachedNetworkImage(
                imageUrl: widget.gameProfile.skillCoverImage,
                label: 'Sample',
                isSample: true,
                onTap: null),
            _buildCachedNetworkImage(
                imageUrl: widget.gameProfile.skillCoverImage,
                label: 'Choose',
                isSample: false,
                onTap: _onTapImage)
          ],
        ));
  }

  Widget _buildCachedNetworkImage(
      {String imageUrl, String label, bool isSample, Function onTap}) {
    return Expanded(
      child: InkResponse(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _skillCoverPhoto != null && isSample == false
                  ? Image.file(_skillCoverPhoto, height: 150, fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      imageBuilder: (context, imageProvider) => Container(
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) =>
                          CupertinoActivityIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
              SizedBox(height: 10),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Column(
      children: <Widget>[
        SizedBox(height: 10),
        Divider(thickness: 2, indent: 32, endIndent: 32),
        SizedBox(height: 10)
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        color: Theme.of(context).backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text('Submit'),
        onPressed: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.gameProfile.gameName),
          actions: <Widget>[
            StreamBuilder<UpdateOrSubmitButtonState>(
                stream: _submitOrUpdateSubject.stream,
                builder: (context, snapshot) {
                  if (snapshot.data == UpdateOrSubmitButtonState.initial) {
                    return CupertinoButton(
                      child: Text(
                          '${widget.gameProfile.isPlay == 0 ? 'Submit' : 'Update'}'),
                      onPressed: _onSubmitOrUpdate,
                    );
                  } else if (snapshot.data ==
                      UpdateOrSubmitButtonState.loading) {
                    return CupertinoButton(
                      child: CupertinoActivityIndicator(),
                      onPressed: null,
                    );
                  } else {
                    return CupertinoButton(
                      child: Text(
                          '${widget.gameProfile.isPlay == 0 ? 'Submit' : 'Update'}'),
                      onPressed: _onSubmitOrUpdate,
                    );
                  }
                })
          ],
        ),
        body: SafeArea(
          child: ListView(
            physics: ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
            children: <Widget>[
              _buildTitleWidget(title: 'Fill your game information'),
              _buildGameProfileCard(
                  title: 'Game ID',
                  subtitle: _gameIdController.text,
                  iconData: Icons.edit,
                  onTap: _onTapGameID),
              _buildGameProfileCard(
                  title: 'Game Rank',
                  subtitle: _level,
                  iconData: Icons.edit,
                  onTap: _onTapLevel),
              _buildDivider(),
              _buildTitleWidget(
                  title: 'Game Mode that you are ready to provide services'),
              _buildGameProfileCard(
                  title: 'Game Mode',
                  subtitle: _gameMode,
                  iconData: Icons.edit,
                  onTap: _onTapGameMode),
              _buildDivider(),
              _buildTitleWidget(
                  title:
                      'Upload the screenshot to prove your game ID and rank'),
              _buildGameProfilePhotoCard(),
            ],
          ),
        ));
  }

  ///update game mode
  _onDone(List<int> newSelectedGameModeIndex) {
    _selectedGameModeIndex = List.from(newSelectedGameModeIndex);
    setState(() {
      _updateGameMode();
    });
  }

  _onSubmitOrUpdate() async {
    if (_gameIdController.text.isEmpty) {
      showToast('Game ID can\'t be blanked');
      return;
    }
    if (_level.isEmpty) {
      showToast('Level can\'t be blanked');
      return;
    }
    if (_gameMode.isEmpty) {
      showToast('Game Mode can\'t be blanked');
      return;
    }
    if (widget.gameProfile.isPlay == 0 && _skillCoverPhoto == null) {
      showToast('ScreenShot can\'t be blanked');
      return;
    }
    _freezeUI();

    ///validation success. send data to server.
    MultipartFile skillCoverImage;
    if (_skillCoverPhoto != null) {
      skillCoverImage = await MultipartFile.fromFile(_skillCoverPhoto.path);
    }
    List<String> mapKeys = [
      'game_id',
      'player_id',
      'level',
      if(skillCoverImage != null) 'skill_cover_image',
      'about_order_taking',
      'types'
    ];
    List<dynamic> mapValues = [
      widget.gameProfile.gameId,
      _gameIdController.text,
      _level,
      if(skillCoverImage != null) skillCoverImage,
      '',
      _selectedGameModeIndex
    ];
    Map<String, dynamic> gameProfileMap = Map.fromIterables(mapKeys, mapValues);
    gameProfileMap.forEach((key, value) {
      print(key + ': ' + '$value');
    });
    MoonBlinkRepository.updateGameProfile(gameProfileMap).then(
        (value) => {
              showToast('Update Success'),
              Navigator.pop(context, true)
            },
        onError: (e) => {showToast(e.toString()), _unfreezeUI()});
  }

  _freezeUI() {
    setState(() {
      _isUILocked = true;
      _submitOrUpdateSubject.add(UpdateOrSubmitButtonState.loading);
    });
  }

  _unfreezeUI() {
    setState(() {
      _isUILocked = false;
      _submitOrUpdateSubject.add(UpdateOrSubmitButtonState.initial);
    });
  }

  _onTapGameID() {
    if (_isUILocked) return;
    if (Platform.isAndroid) {
      _showMaterialDialog(context, _gameIdController);
    } else if (Platform.isIOS) {
      _showCupertinoDialog(context, _gameIdController);
    } else {
      showToast('This platform is not supported.');
    }
  }

  _onTapLevel() {
    if (_isUILocked) return;
    _showCupertinoBottomSheet(context);
  }

  _onTapGameMode() {
    if (_isUILocked) return;
    CustomBottomSheet.showGameModeBottomSheet(
        buildContext: context,
        gameModeList: List.from(_gameModeList),
        selectedGameModeIndex: List.from(_selectedGameModeIndex),
        onDone: (newSelectedGameModeIndex) =>
            _onDone(newSelectedGameModeIndex));
  }

  _onTapImage() {
    if (_isUILocked) return;
    CustomBottomSheet.show(
        buildContext: context,
        limit: 1,
        body: 'Skill Cover Photo',
        onPressed: (File file) {
          setState(() {
            _skillCoverPhoto = file;
          });
        },
        buttonText: 'Choose',
        popAfterBtnPressed: true,
        requestType: RequestType.image);
  }
}
