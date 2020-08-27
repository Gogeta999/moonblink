import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/selected_image_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

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
      @required this.minHeight})
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
                  child: FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(G.of(context).cancel,
                        style: Theme.of(context).textTheme.bodyText1),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (_albums.isNotEmpty)
                        Text('${_albums[_currentAlbum].name}',
                            style: Theme.of(context).textTheme.bodyText1),
                      SizedBox(height: 5),
                      Text('${widget.body}',
                          style: Theme.of(context).textTheme.bodyText1)
                    ],
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: () {
                      showModalBottomSheet<int>(
                          context: context,
                          barrierColor: Colors.white.withOpacity(0.0),
                          isScrollControlled: true,
                          isDismissible: true,
                          builder: (context) {
                            return Container(
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
                                          child: FlatButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(G.of(context).cancel,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1),
                                          ),
                                        ),
                                        Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                                G.of(context).labelalbumselect,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1))
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
                          print(value);
                          _switchAlbum(value);
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(G.of(context).albums,
                            style: Theme.of(context).textTheme.bodyText1),
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
                    child: RaisedButton(
                      onPressed: _choose,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${widget.buttonText}',
                          style: TextStyle(fontSize: 16)),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      color: Theme.of(context).accentColor,
                    ),
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

  Future<File> _compressAndGetFile(
      File file, String targetPath, int minWidth, int minHeight) async {
    ///compress to jpeg and change aspect ratio to 1:1
    ///minWidth and minHeight default to 1080
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: 90,
        format: CompressFormat.jpeg);

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File(
        '$path/' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpeg');
  }

  _choose() async {
    ///can improve with Navigator.pop with result.
    if (widget.popAfterBtnPressed) {
      Navigator.pop(context);
    }
    File image = await _photoList[_selectedIndices.first].file;
    File temporaryImage = await _getLocalFile();
    File compressedImage = await _compressAndGetFile(
        image, temporaryImage.absolute.path, widget.minWidth, widget.minHeight);
    widget.onPressed(compressedImage);
  }

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
      setState(() {
        _selectedImages.add(SelectedImageModel(thumbnail: thumbnail));
      });
    }
    print(_photoList);
    print(_albums);
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
        print('Fetching');
        _addNewPhotos();
      }
    }
  }
}
