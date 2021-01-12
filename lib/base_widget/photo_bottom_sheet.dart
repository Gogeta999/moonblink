import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/videotrimmer/trimmer_view.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/selected_image_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/subjects.dart';
import 'package:video_trimmer/video_trimmer.dart';

class PhotoBottomSheet extends StatefulWidget {
  final ScrollController sheetScrollController;
  final int limit;
  final Function onPressed;
  final RequestType requestType;
  final String body;
  final String buttonText;
  final bool popAfterBtnPressed;
  final int minWidth;
  final int minHeight;
  final bool willCrop;
  final bool defaultCropStyle;
  final int compressQuality;
  final int vipLevel;

  const PhotoBottomSheet(
      {Key key,
      @required this.sheetScrollController,
      @required this.limit,
      @required this.onPressed,
      @required this.requestType,
      @required this.body,
      @required this.buttonText,
      @required this.popAfterBtnPressed,
      @required this.minWidth,
      @required this.minHeight,
      @required this.willCrop,
      @required this.defaultCropStyle,
      @required this.compressQuality,
      this.vipLevel})
      : super(key: key);

  @override
  _PhotoBottomSheetState createState() => _PhotoBottomSheetState();
}

class _PhotoBottomSheetState extends State<PhotoBottomSheet> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 2000.0;
  int _currentPage = 0;
  int _pageSize = 50;
  int _currentAlbum = 0;
  bool _hasReachedMax = false;
  bool _isFetching = false;
  final _selectButtonSubject = BehaviorSubject.seeded(false);

  List<AssetPathEntity> _albums = [];
  List<AssetEntity> _photoList = [];
  List<SelectedImageModel> _selectedImages = [];
  List<Uint8List> _albumFirstThumbnailList = [];
  List<int> _selectedIndices = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchNewMedia();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _selectButtonSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SingleChildScrollView(
          controller: widget.sheetScrollController,
          physics: ClampingScrollPhysics(),
          child: Container(
            margin: EdgeInsets.all(5),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(G.of(context).cancel),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (_albums.isNotEmpty)
                        Text('${_albums[_currentAlbum].name}',
                            style: TextStyle(
                                color: Theme.of(context).accentColor)),
                      SizedBox(height: 5),
                      Text('${widget.body}',
                          style:
                              TextStyle(color: Theme.of(context).accentColor))
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    onPressed: () {
                      showModalBottomSheet<int>(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.6),
                          isScrollControlled: true,
                          isDismissible: true,
                          builder: (context) {
                            return Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              height: MediaQuery.of(context).size.height * 0.9,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: CupertinoButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(G.of(context).cancel),
                                          ),
                                        ),
                                        Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                                G.of(context).labelalbumselect,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .accentColor)))
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _albums.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                            onTap: () =>
                                                Navigator.pop(context, index),
                                            selected: index == _currentAlbum,
                                            leading: Container(
                                                width: 60,
                                                height: 64,
                                                child: Image.memory(
                                                    _albumFirstThumbnailList[
                                                        index],
                                                    fit: BoxFit.cover)),
                                            title:
                                                Text('${_albums[index].name}'),
                                            subtitle: Text(
                                                '${_albums[index].assetCount}'),
                                            trailing: Icon(
                                              Icons.check,
                                              color: index == _currentAlbum
                                                  ? Colors.blue
                                                  : Colors.transparent,
                                            ));
                                      },
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).then((value) {
                        if (value != null && value != _currentAlbum) {
                          _switchAlbum(value);
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(child: Text(G.of(context).albums)),
                        SizedBox(width: 5),
                        Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              GridView.builder(
                  addAutomaticKeepAlives: true,
                  controller: _scrollController,
                  physics: ClampingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _onTapImage(index),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Image.memory(
                            _selectedImages[index].thumbnail,
                            color: _selectedImages[index].isSelected
                                ? Colors.white70
                                : Colors.transparent,
                            colorBlendMode: BlendMode.lighten,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          if (_selectedImages[index].duration > 0)
                            Positioned(
                                top: 10,
                                right: 40,
                                child: Center(
                                    child: Text(
                                        '${_selectedImages[index].formattedDuration}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1))),
                          if (_selectedImages[index].isSelected)
                            Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  child: Center(
                                      child: Text(
                                          '${_selectedIndices.indexOf(index) + 1}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1)),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).backgroundColor,
                                  ),
                                )),
                        ],
                      ),
                    );
                  }),
              if (_selectedIndices.isNotEmpty)
                Positioned(
                  bottom: 20,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: StreamBuilder<bool>(
                        initialData: false,
                        stream: this._selectButtonSubject,
                        builder: (context, snapshot) {
                          if (snapshot.data) {
                            return RaisedButton(
                              onPressed: () {},
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: CupertinoActivityIndicator(),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              color: Theme.of(context).accentColor,
                            );
                          }
                          return RaisedButton(
                            onPressed: _choose,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('${widget.buttonText}',
                                style: TextStyle(fontSize: 16)),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            color: Theme.of(context).accentColor,
                          );
                        }),
                  ),
                )
            ],
          ),
        )
      ],
    );
  }

  _onTapImage(int index) async {
    setState(() {
      _selectedImages[index].isSelected = !_selectedImages[index].isSelected;
      _selectedImages[index].isSelected
          ? _selectedIndices.add(index)
          : _selectedIndices.remove(index);
      if (_selectedIndices.length >= widget.limit + 1) {
        _selectedImages[_selectedIndices.first].isSelected = false;
        _selectedIndices.remove(_selectedIndices.first);
      }
    });
  }

  // 2. compress file and get file.
  Future<File> _compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        quality: widget.compressQuality,
        minWidth: widget.minWidth,
        minHeight: widget.minHeight);

    if (isDev) print(file.lengthSync());
    if (isDev) print(result.lengthSync());

    return result;
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final filePath =
        '$path/' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpeg';
    return File(filePath);
  }

  Future<File> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
        cropStyle:
            widget.defaultCropStyle ? CropStyle.rectangle : CropStyle.circle,
        sourcePath: imageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(showCancelConfirmationDialog: true));
    if (croppedFile != null) {
      return croppedFile;
    } else {
      return null;
    }
  }

  _choose() async {
    _selectButtonSubject.add(true);
    if (widget.requestType == RequestType.image) {
      List<File> compressedImages = [];
      for (int i = 0; i < _selectedIndices.length; ++i) {
        File image = await _photoList[_selectedIndices[i]].file;
        File croppedImage;
        File tempFile = await _getLocalFile();
        if (widget.willCrop) {
          croppedImage = await _cropImage(image);
        }
        if (widget.willCrop && croppedImage == null) {
          return;
        }
        File compressedImage =
            await _compressAndGetFile(croppedImage ?? image, tempFile.path);
        compressedImages.add(compressedImage);
      }

      ///can improve with Navigator.pop with result.
      if (widget.popAfterBtnPressed) {
        Navigator.pop(context);
      }
      _selectButtonSubject.add(false);
      if (compressedImages.isNotEmpty) {
        widget.onPressed(compressedImages);
      } else {
        if (isDev) print('CompressedImages is empty');
      }
    } else if (widget.requestType == RequestType.video &&
        widget.vipLevel != null) {
      final _trimmer = Trimmer();
      File video = await _photoList[_selectedIndices.first].file;
      if (video != null) {
        await _trimmer.loadVideo(videoFile: video);
        File trimmedCompressedVideo = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) {
          return TrimmerView(_trimmer, widget.vipLevel);
        }));
        _selectButtonSubject.add(false);
        if (widget.popAfterBtnPressed) {
          Navigator.pop(context);
        }
        if (trimmedCompressedVideo != null) {
          widget.onPressed(trimmedCompressedVideo);
        }
      }
    } else {
      //Request type not supported
      Navigator.pop(context);
    }
  }
  // _choose() async {
  //   ///can improve with Navigator.pop with result.
  //   if (widget.popAfterBtnPressed) {
  //     Navigator.pop(context);
  //   }
  //   if (widget.requestType == RequestType.image) {
  //     List<File> compressedImages = [];
  //     for (int i = 0; i < _selectedIndices.length; ++i) {
  //       File image = await _photoList[_selectedIndices[i]].file;
  //       File croppedImage;
  //       File tempFile = await _getLocalFile();
  //       if (widget.willCrop) {
  //         croppedImage = await _cropImage(image);
  //       }
  //       if (widget.willCrop && croppedImage == null) {
  //         return;
  //       }
  //       File compressedImage =
  //           await _compressAndGetFile(croppedImage ?? image, tempFile.path);
  //       compressedImages.add(compressedImage);
  //     }
  //     if (compressedImages.isNotEmpty) {
  //       widget.onPressed(compressedImages);
  //     } else {
  //       if (isDev) print('CompressedImages is empty');
  //     }
  //   } else if (widget.requestType == RequestType.video) {
  //     final _trimmer = Trimmer();
  //     File video = await _photoList[_selectedIndices.first].file;
  //     if (video != null) {
  //       await _trimmer.loadVideo(videoFile: video);
  //       File trimmedVideo = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  //         return TrimmerView(_trimmer);
  //       }));
  //       print("Trimmed Video: ${trimmedVideo.lengthSync()}");
  //       MediaInfo mediaInfo = await VideoCompress.compressVideo(
  //         trimmedVideo.path,
  //         quality: VideoQuality.DefaultQuality,
  //         deleteOrigin: true,
  //         includeAudio: true,
  //       );
  //       Uint8List thumbnail = await VideoCompress.getByteThumbnail(mediaInfo.file.path, position: mediaInfo.duration ~/ 2);
  //       print("Compressed Video: ${mediaInfo.filesize}");
  //       if (mediaInfo.file != null) {
  //         widget.onPressed(mediaInfo.file, thumbnail);
  //       }
  //     }
  //   } else {
  //     //Request type not supported
  //   }
  // }

  _fetchNewMedia() async {
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        hasAll: true, type: widget.requestType);
    if (albums.isEmpty) {
      return;
    }
    albums.sort((a, b) => a.assetCount > b.assetCount ? 0 : 1);
    albums.forEach((album) {
      setState(() {
        _albums.add(album);
        album.getAssetListRange(start: 0, end: 1).then((value) async =>
            _albumFirstThumbnailList
                .add(await value.first.thumbDataWithSize(60, 64)));
      });
    });
    await _addNewPhotos();
  }

  _addNewPhotos() async {
    _isFetching = true;
    List<AssetEntity> photos =
        await _albums[_currentAlbum].getAssetListPaged(_currentPage, _pageSize);
    if (photos.length < _pageSize) {
      _hasReachedMax = true;
    }
    for (var photo in photos) {
      Uint8List thumbnail = await photo.thumbDataWithSize(150, 150);
      final minutes = (photo.duration ~/ 60).toString();
      final seconds = (photo.duration % 60).toString().padLeft(2, "0");
      setState(() {
        _selectedImages.add(SelectedImageModel(
            thumbnail: thumbnail,
            duration: photo.duration,
            formattedDuration: "$minutes:$seconds"));
      });
    }
    setState(() {
      _photoList.addAll(photos);
      _currentPage++;
      _isFetching = false;
    });
  }

  _switchAlbum(int value) {
    _currentAlbum = value;
    _currentPage = 0;
    _photoList.clear();
    _selectedImages.clear();
    _selectedIndices.clear();
    _hasReachedMax = false;
    _addNewPhotos();
    _scrollController.jumpTo(0.0);
  }

  void _onScroll() {
    if (_isFetching) {
      return;
    }
    if (!_hasReachedMax) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold) {
        _addNewPhotos();
      }
    }
  }
}
