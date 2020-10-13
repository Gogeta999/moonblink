import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/game_profile.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/compress_utils.dart';
import 'package:moonblink/utils/constants.dart';
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
  List<Map<String, int>> _selectedGameModeIndex = [];
  File _skillCoverPhoto;

  ///UI properties
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
    super.dispose();
  }

  _initWithRemoteData() {
    _gameModeList = List.unmodifiable(widget.gameProfile.gameModeList);
    _gameIdController.text = widget.gameProfile.playerId;
    _level = widget.gameProfile.level;
    for (int i = 0; i < _gameModeList.length; ++i) {
      if (_gameModeList[i].selected == 1) {
        _selectedGameModeIndex
            .add({_gameModeList[i].id.toString(): _gameModeList[i].price});
      }
    }

    _updateGameMode();

    widget.gameProfile.gameRankList.forEach((element) {
      _cupertinoActionSheet.add(
        CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _level = element;
              });
              Navigator.pop(context);
            },
            child: Text(element, style: _textStyle)),
      );
    });
  }

  _updateGameMode() {
    _gameMode = '';
    for (int i = 0; i < _gameModeList.length; ++i) {
      bool isSelected = false;
      _selectedGameModeIndex.forEach((element) {
        if (element.containsKey(_gameModeList[i].id.toString())) {
          isSelected = true;
          return;
        }
      });
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
            title: Text(G.of(context).labelid, textAlign: TextAlign.center),
            content: CupertinoTextField(
              decoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
              controller: controller,
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text(G.of(context).cancel),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
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
            title: Text(G.of(context).labelid, textAlign: TextAlign.center),
            content: CupertinoTextField(
              decoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
              controller: controller,
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: Text(G.of(context).cancel),
              ),
              CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                child: Text(G.of(context).submit),
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
            title: Text(G.of(context).selectgamerank),
            actions: _cupertinoActionSheet,
            cancelButton: CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: Text(G.of(context).cancel),
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
    String gameProfileSample = widget.gameProfile.gameProfileSample;
    return Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 8,
        child: Row(
          children: <Widget>[
            ///for now skill cover image later server will give a sample photo url
            _buildCachedNetworkImage(
                imageUrl: gameProfileSample.isEmpty || null
                    ? widget.gameProfile.skillCoverImage
                    : gameProfileSample,
                label: G.of(context).sample,
                isSample: true,
                onTap: null),
            _buildCachedNetworkImage(
                imageUrl: widget.gameProfile.skillCoverImage,
                label: G.of(context).select,
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
        child: Text(G.of(context).submit),
        onPressed: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(widget.gameProfile.gameName),
          leading: IconButton(
              icon: Icon(CupertinoIcons.back),
              onPressed: () {
                Navigator.pop(context);
              }),
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
          // elevation: 15,
          // shadowColor: Colors.blue,
          bottom: PreferredSize(
              child: Container(
                height: 10,
                color: Theme.of(context).accentColor,
              ),
              preferredSize: Size.fromHeight(10)),
        ),
//        backgroundColor: Colors.grey[200],
        body: SafeArea(
          child: ListView(
            physics: ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
            children: <Widget>[
              _buildTitleWidget(title: G.of(context).fillgameinfo),
              _buildGameProfileCard(
                  title: G.of(context).gameid,
                  subtitle: _gameIdController.text,
                  iconData: Icons.edit,
                  onTap: _onTapGameID),
              _buildGameProfileCard(
                  title: G.of(context).gamerank,
                  subtitle: _level,
                  iconData: Icons.edit,
                  onTap: _onTapLevel),
              _buildDivider(),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 8,
                child: ListTile(
                  onTap: null,
                  title: Text(
                    G.current.alarmRatio,
                    // style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
              _buildDivider(),
              _buildTitleWidget(title: G.of(context).gamemodedescript),
              _buildGameProfileCard(
                  title: G.of(context).gamemode,
                  subtitle: _gameMode,
                  iconData: Icons.edit,
                  onTap: _onTapGameMode),
              // _buildDivider(),
              // _buildTitleWidget(title: "Give Price for your Game"),
              // _buildGameProfileCard(
              //     title: G.of(context).gamemode,
              //     subtitle: _gameMode,
              //     iconData: Icons.edit,
              //     onTap: _onTapGameMode),
              _buildDivider(),
              _buildTitleWidget(title: G.of(context).titlescreenshot),
              _buildGameProfilePhotoCard(),
            ],
          ),
        ));
  }

  ///update game mode
  _onDone(List<Map<String, int>> newSelectedGameModeIndex) {
    _selectedGameModeIndex = List.from(newSelectedGameModeIndex);
    setState(() {
      _updateGameMode();
    });
  }

  _onSubmitOrUpdate() async {
    if (_gameIdController.text.isEmpty) {
      showToast('Game ID ${G.of(context).cannotblank}');
      return;
    }
    if (_level.isEmpty) {
      showToast('Level ${G.of(context).cannotblank}');
      return;
    }
    if (_gameMode.isEmpty) {
      showToast('Game Mode ${G.of(context).cannotblank}');
      return;
    }
    if (widget.gameProfile.isPlay == 0 && _skillCoverPhoto == null) {
      showToast('ScreenShot ${G.of(context).cannotblank}');
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
      if (skillCoverImage != null) 'skill_cover_image',
      'about_order_taking',
      'types'
    ];
    List<dynamic> mapValues = [
      widget.gameProfile.gameId,
      _gameIdController.text,
      _level,
      if (skillCoverImage != null) skillCoverImage,
      '',
      _selectedGameModeIndex
    ];
    Map<String, dynamic> gameProfileMap = Map.fromIterables(mapKeys, mapValues);
    gameProfileMap.forEach((key, value) {
      print(key + ': ' + '$value');
    });
    MoonBlinkRepository.updateGameProfile(gameProfileMap).then(
        (value) => {
              showToast(G.of(context).toastsuccess),
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
      showToast(G.of(context).toastplatformnotsupport);
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
    return showCupertinoDialog(
      context: context,
      builder: (builder) => CupertinoAlertDialog(
        content: Text(G.of(context).pickimage),
        actions: <Widget>[
          CupertinoButton(
              child: Text(G.of(context).imagePickerGallery),
              onPressed: () {
                CustomBottomSheet.show(
                    buildContext: context,
                    limit: 1,
                    body: G.of(context).skillcover,
                    onPressed: (File file) {
                      setState(() {
                        _skillCoverPhoto = file;
                      });
                    },
                    buttonText: G.of(context).select,
                    popAfterBtnPressed: true,
                    requestType: RequestType.image,
                    willCrop: false,
                    compressQuality: NORMAL_COMPRESS_QUALITY);
                Navigator.pop(context);
              }),
          CupertinoButton(
            child: Text(G.of(context).imagePickerCamera),
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
          ),
          CupertinoButton(
            child: Text(G.of(context).cancel),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  _pickImageFromCamera() async {
    PickedFile pickedFile =
        await ImagePicker().getImage(source: ImageSource.camera);
    File compressedImage = await CompressUtils.compressAndGetFile(
        File(pickedFile.path), 90, 1080, 1080);
    setState(() {
      _skillCoverPhoto = compressedImage;
    });
  }
}
