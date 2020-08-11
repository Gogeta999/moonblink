import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/models/selected_image_model.dart';
import 'package:photo_manager/photo_manager.dart';

class CustomBottomSheet {
  static show(
      {@required BuildContext buildContext,
      @required int limit,
      @required String body,
      @required Function onPressed,
      @required String buttonText,
      @required bool popAfterBtnPressed,
      Function onDismiss}) {
    showModalBottomSheet(
        context: buildContext,
        barrierColor: Colors.white.withOpacity(0.0),
        isDismissible: true,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
              expand: false,
              maxChildSize: 0.90,
              builder: (context, scrollController) {
                return PhotoBottomSheet(
                  sheetScrollController: scrollController,
                  popAfterBtnPressed: popAfterBtnPressed,
                  limit: limit,
                  onPressed: onPressed,
                  body: body,
                  buttonText: buttonText
                );
              },
            )).whenComplete(onDismiss);
  }
}

class PhotoBottomSheet extends StatefulWidget {
  final ScrollController sheetScrollController;
  final int limit;
  final Function onPressed;
  final String body;
  final String buttonText;
  final bool popAfterBtnPressed;

  const PhotoBottomSheet(
      {Key key,
      @required this.sheetScrollController,
      @required this.limit,
      @required this.onPressed,
      @required this.body,
      @required this.buttonText,
      @required this.popAfterBtnPressed})
      : super(key: key);

  @override
  _PhotoBottomSheetState createState() => _PhotoBottomSheetState();
}

class _PhotoBottomSheetState extends State<PhotoBottomSheet> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 400.0;
  int _currentPage = 0;
  int _pageSize = 50;
  bool _hasReachedMax = false;
  bool _isFetching = false;

  List<AssetPathEntity> _albums = [];
  List<AssetEntity> _photoList = [];
  //List<Uint8List> _thumbnailList = [];
  List<SelectedImageModel> _selectedImages = [];
  Set<int> _selectedIndices = Set();

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
          child: Container(
            margin: EdgeInsets.all(5),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',
                        style: Theme.of(context).textTheme.bodyText1),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (_albums.isNotEmpty)
                        Text('${_albums.first.name}',
                            style: Theme.of(context).textTheme.bodyText1),
                      SizedBox(height: 5),
                      Text('${widget.body}',
                          style: Theme.of(context).textTheme.bodyText1)
                    ],
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Albums',
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
                          fit: BoxFit.cover,
                          color: _selectedImages[index].isSelected
                              ? Colors.white70
                              : Colors.transparent,
                          colorBlendMode: BlendMode.lighten,
                        ),
                        if (_selectedImages[index].isSelected)
                          Positioned(
                            top: 10,
                            right: 10,
                            child:
                                Icon(Icons.check_circle, color: Colors.blue),
                          ),
                      ],
                    ),
                  );
                }),
              if (_selectedIndices.isNotEmpty)
                Positioned(
                  bottom: 20,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: RaisedButton(
                      onPressed: _choose,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${widget.buttonText}'),
                      padding: EdgeInsets.symmetric(vertical: 10),
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

  _choose() async {
    widget.onPressed(await _photoList[_selectedIndices.first].file);
    if(widget.popAfterBtnPressed) {
      Navigator.pop(context);
    }
  }

  _fetchNewMedia() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
      //load the album list
      _albums = await PhotoManager.getAssetPathList(
          onlyAll: true, type: RequestType.image);
      await _addNewPhotos();
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }

  _addNewPhotos() async {
    _isFetching = true;
    List<AssetEntity> photos =
        await _albums.first.getAssetListPaged(_currentPage, _pageSize);
    if (photos.length < _pageSize) {
      _hasReachedMax = true;
    }
    for (var photo in photos) {
      Uint8List thumbnail = await photo.thumbDataWithSize(120, 150);
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
