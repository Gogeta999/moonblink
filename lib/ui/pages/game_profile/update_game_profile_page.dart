import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/bloc_pattern/update_game_profile/bloc/update_game_profile_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/utils/compress_utils.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

class UpdateGameProfilePage extends StatefulWidget {
  @override
  _UpdateGameProfilePageState createState() => _UpdateGameProfilePageState();
}

class _UpdateGameProfilePageState extends State<UpdateGameProfilePage> {
  UpdateGameProfileBloc _updateGameProfileBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateGameProfileBloc.textStyle = Theme.of(context).textTheme.bodyText1;
  }

  @override
  void initState() {
    _updateGameProfileBloc = BlocProvider.of<UpdateGameProfileBloc>(context);
    _updateGameProfileBloc.initWithRemoteData();
    super.initState();
  }

  @override
  void dispose() {
    _updateGameProfileBloc.dispose();
    super.dispose();
  }

  _showMaterialDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(G.of(context).labelid, textAlign: TextAlign.center),
            content: CupertinoTextField(
              autofocus: true,
              decoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
              controller: _updateGameProfileBloc.gameIdController,
              textAlign: TextAlign.center,
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

  _showCupertinoDialog(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(G.of(context).labelid, textAlign: TextAlign.center),
            content: CupertinoTextField(
              autofocus: true,
              decoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
              controller: _updateGameProfileBloc.gameIdController,
              textAlign: TextAlign.center,
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

  _showCupertinoBottomSheet(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(G.of(context).selectgamerank),
            actions: _updateGameProfileBloc.cupertinoActionSheet,
            cancelButton: CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: Text(G.of(context).cancel),
            ),
          );
        });
  }

  _showCupertinoBottomSheetForBoosting(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(G.of(context).selectgamerank),
            actions: _updateGameProfileBloc.cupertinoActionSheetForBoosting,
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
    String gameProfileSample =
        _updateGameProfileBloc.gameProfile.gameProfileSample;
    return Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 8,
        child: Column(
          children: [
            Row(
              children: <Widget>[
                ///for now skill cover image later server will give a sample photo url
                _buildCachedNetworkImage(
                    imageUrl:
                        gameProfileSample.isEmpty || gameProfileSample == null
                            ? _updateGameProfileBloc.gameProfile.skillCoverImage
                            : gameProfileSample,
                    isSample: true,
                    onTap: null),
                StreamBuilder<File>(
                  initialData: null,
                  stream: _updateGameProfileBloc.skillCoverPhotoSubject,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    } else if (snapshot.data == null &&
                        (_updateGameProfileBloc.gameProfile.skillCoverImage ==
                                null ||
                            _updateGameProfileBloc
                                .gameProfile.skillCoverImage.isEmpty)) {
                      return Expanded(
                          child: InkResponse(
                              onTap: _onTapImage,
                              child: Container(
                                  margin: const EdgeInsets.all(16),
                                  child: Icon(Icons.add_box, size: 52))));
                    } else {
                      return _buildCachedNetworkImage(
                          imageUrl: _updateGameProfileBloc
                              .gameProfile.skillCoverImage,
                          isSample: false,
                          onTap: _onTapImage);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(G.of(context).sample),
                InkResponse(
                    onTap: _onTapImage, child: Text(G.of(context).select))
              ],
            ),
            SizedBox(height: 10),
          ],
        ));
  }

  Widget _buildCachedNetworkImage(
      {String imageUrl, bool isSample, Function onTap}) {
    return Expanded(
      child: InkResponse(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 2),
          child: StreamBuilder<File>(
            initialData: null,
            stream: _updateGameProfileBloc.skillCoverPhotoSubject,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('${snapshot.error}');
              } else if (snapshot.data != null && isSample == false) {
                return Image.file(snapshot.data,
                    height: 150, fit: BoxFit.cover);
              } else {
                return CachedNetworkImage(
                  imageUrl: imageUrl,
                  imageBuilder: (context, imageProvider) => Container(
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => CupertinoActivityIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                );
              }
            },
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

  Widget _buildBookingSwitch() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 8,
      child: ListTile(
        title: Text("Want to provide Booking Service"),
        trailing: StreamBuilder<bool>(
            initialData: false,
            stream: _updateGameProfileBloc.bookingSwitchSubject,
            builder: (context, snapshot) {
              return CupertinoSwitch(
                value: snapshot.data,
                onChanged: (value) =>
                    _updateGameProfileBloc.onChangedBookingSwitch(value),
              );
            }),
      ),
    );
  }

  Widget _buildBookingService() {
    return StreamBuilder<bool>(
        initialData: false,
        stream: _updateGameProfileBloc.bookingSwitchSubject,
        builder: (context, snapshot) {
          if (!snapshot.data) return Container();
          return Column(
            children: [
              SizedBox(height: 5),
              _buildTitleWidget(title: G.of(context).gamemodedescript),
              StreamBuilder<String>(
                  initialData: '',
                  stream: _updateGameProfileBloc.gameModeSubject,
                  builder: (context, snapshot) {
                    return _buildGameProfileCard(
                        title: G.of(context).gamemode,
                        subtitle: snapshot.data,
                        iconData: Icons.edit,
                        onTap: _onTapGameMode);
                  }),
            ],
          );
        });
  }

  Widget _buildBoostingSwitch() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 8,
      child: ListTile(
        title: Text("Want to provide Boosting Service"),
        trailing: StreamBuilder<bool>(
            initialData: false,
            stream: _updateGameProfileBloc.boostingSwitchSubject,
            builder: (context, snapshot) {
              return CupertinoSwitch(
                value: snapshot.data,
                onChanged: (value) =>
                    _updateGameProfileBloc.onChangedBoostingSwitch(value),
              );
            }),
      ),
    );
  }

  Widget _buildBoostingService() {
    return StreamBuilder<bool>(
        initialData: false,
        stream: _updateGameProfileBloc.boostingSwitchSubject,
        builder: (context, snapshot) {
          if (!snapshot.data) return Container();
          return Column(
            children: [
              SizedBox(height: 5),
              _buildTitleWidget(
                  title:
                      "Highest rank that you are ready to provide Boosting Service"),
              StreamBuilder<String>(
                  initialData: '',
                  stream: _updateGameProfileBloc.boostingLevelSubject,
                  builder: (context, snapshot) {
                    return _buildGameProfileCard(
                        title: "Highest Rank",
                        subtitle: snapshot.data,
                        iconData: Icons.edit,
                        onTap: _onTapHighestLevel);
                  }),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(_updateGameProfileBloc.gameProfile.gameName),
          leading: IconButton(
              icon: Icon(CupertinoIcons.back),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: <Widget>[
            StreamBuilder<UpdateOrSubmitButtonState>(
                stream: _updateGameProfileBloc.submitOrUpdateSubject.stream,
                builder: (context, snapshot) {
                  if (snapshot.data == UpdateOrSubmitButtonState.initial) {
                    return CupertinoButton(
                      child: Text(
                          '${_updateGameProfileBloc.gameProfile.isPlay == 0 ? 'Submit' : 'Update'}'),
                      onPressed: _updateGameProfileBloc.onSubmitOrUpdate,
                    );
                  } else if (snapshot.data ==
                      UpdateOrSubmitButtonState.loading) {
                    return CupertinoButton(
                      child: CupertinoActivityIndicator(),
                      onPressed: () {},
                    );
                  } else {
                    return CupertinoButton(
                      child: Text(
                          '${_updateGameProfileBloc.gameProfile.isPlay == 0 ? 'Submit' : 'Update'}'),
                      onPressed: _updateGameProfileBloc.onSubmitOrUpdate,
                    );
                  }
                })
          ],
          bottom: PreferredSize(
              child: Container(
                height: 10,
                color: Theme.of(context).accentColor,
              ),
              preferredSize: Size.fromHeight(10)),
        ),
        body: SafeArea(
          child: ListView(
            physics: ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
            children: <Widget>[
              _buildTitleWidget(title: G.of(context).fillgameinfo),
              _buildGameProfileCard(
                  title: G.of(context).gameid,
                  subtitle: _updateGameProfileBloc.gameIdController.text,
                  iconData: Icons.edit,
                  onTap: _onTapGameID),
              StreamBuilder<String>(
                  initialData: '',
                  stream: _updateGameProfileBloc.levelSubject,
                  builder: (context, snapshot) {
                    return _buildGameProfileCard(
                        title: G.of(context).gamerank,
                        subtitle: snapshot.data,
                        iconData: Icons.edit,
                        onTap: _onTapLevel);
                  }),
              _buildDivider(),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 8,
                child: ListTile(
                  onTap: null,
                  title: Text(
                    G.current.alarmRatio,
                  ),
                ),
              ),
              _buildDivider(),
              _buildBookingSwitch(),
              _buildBookingService(),
              _buildDivider(),
              _buildBoostingSwitch(),
              _buildBoostingService(),
              _buildDivider(),
              _buildTitleWidget(title: G.of(context).titlescreenshot),
              _buildGameProfilePhotoCard(),
              SizedBox(height: 20),
            ],
          ),
        ));
  }

  ///update game mode
  // _onDone(List<Map<String, int>> newSelectedGameModeIndex) {
  //   _selectedGameModeIndex = List.from(newSelectedGameModeIndex);
  //   setState(() {
  //     _updateGameMode();
  //   });
  // }

  _onTapGameID() {
    if (_updateGameProfileBloc.isUILocked) return;
    if (Platform.isAndroid) {
      _showMaterialDialog(context);
    } else if (Platform.isIOS) {
      _showCupertinoDialog(context);
    } else {
      showToast(G.of(context).toastplatformnotsupport);
    }
  }

  _onTapLevel() {
    if (_updateGameProfileBloc.isUILocked) return;
    _showCupertinoBottomSheet(context);
  }

  _onTapHighestLevel() {
    if (_updateGameProfileBloc.isUILocked) return;
    _showCupertinoBottomSheetForBoosting(context);
  }

  _onTapGameMode() {
    if (_updateGameProfileBloc.isUILocked) return;
    CustomBottomSheet.showGameModeBottomSheet(
        buildContext: context,
        onDismiss: () {
          if (_updateGameProfileBloc.selectedGameModeIndex.isNotEmpty) {
            _updateGameProfileBloc.selectedGameModeIndex.sort((a, b) =>
                int.tryParse(a.keys.first) > int.tryParse(b.keys.first)
                    ? 1
                    : 0);
          }
          _updateGameProfileBloc.updateGameMode();
        });
  }

  _onTapImage() {
    if (_updateGameProfileBloc.isUILocked) return;
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
                      _updateGameProfileBloc.skillCoverPhotoSubject.add(file);
                    },
                    buttonText: G.of(context).select,
                    popAfterBtnPressed: true,
                    requestType: RequestType.image,
                    minHeight: 500,
                    minWidth: 500,
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
        File(pickedFile.path), NORMAL_COMPRESS_QUALITY, 500, 500);
    _updateGameProfileBloc.skillCoverPhotoSubject.add(compressedImage);
  }
}
