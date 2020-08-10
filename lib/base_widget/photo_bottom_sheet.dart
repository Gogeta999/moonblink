// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:local_image_provider/device_image.dart';
// import 'package:local_image_provider/local_album.dart';
// import 'package:local_image_provider/local_image.dart';
// import 'package:local_image_provider/local_image_provider.dart';
// import 'package:moonblink/models/selected_image_model.dart';
// import 'package:photo_manager/photo_manager.dart';

// class PhotoBottomSheet extends StatefulWidget {

//   final ScrollController scrollController;

//   const PhotoBottomSheet({Key key, this.scrollController}) : super(key: key);

//   @override
//   _PhotoBottomSheetState createState() => _PhotoBottomSheetState();
// }

// class _PhotoBottomSheetState extends State<PhotoBottomSheet> {
//   final _scrollThreshold = 400.0;
//   int _currentPage = 0;
//   int _pageSize = 100;
//   bool _hasReachedMax = false;
//   bool _isFetching = false;

//   List<AssetPathEntity> _albums = [];
//   List<AssetEntity> _photoList = [];
//   List<Uint8List> _thumbnailList = [];
//   List<SelectedImageModel> _selectedImages = [];

//   @override
//   void initState() {
//     super.initState();
//     widget.scrollController.addListener(_onScroll);
//     _fetchNewMedia();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       controller: widget.scrollController,
//       slivers: <Widget>[
//         SliverToBoxAdapter(
//           child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: <Widget>[
//                 Text('Selected ${_selectedImages.length}',
//                     style: Theme.of(context).textTheme.bodyText1),
//                 FlatButton(
//                   onPressed: () async {
//                     //send images
//                     if(_selectedImages.isNotEmpty) {
//                       Set<Uint8List> toSend = Set();
//                       for (var image in _selectedImages) {
//                         toSend.add(await image.getImageBytes());
//                       }
//                       File file = File.fromRawPath(toSend.first);
//                       print('Successfully Sent');
//                       Navigator.pop(context);
//                     }
//                   },
//                   child: Text('Send', style: Theme.of(context).textTheme.bodyText1),
//                 )
//               ]
//           ),
//         ),
//         SliverGrid(
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3
//           ),
//           delegate: SliverChildBuilderDelegate(
//                 (context, index) {
//               return Image.memory(
//                 _thumbnailList[index],
//                 fit: BoxFit.cover,
//               );
//             },
//             childCount: _photoList.length,
//           ),
//         ),
//       ],
//     );
//   }

//   _fetchNewMedia() async {
//     var result = await PhotoManager.requestPermission();
//     if (result) {
//       // success
//       //load the album list
//       _albums =
//       await PhotoManager.getAssetPathList(onlyAll: true, type: RequestType.image);
//       await _addNewPhotos();
//     } else {
//       // fail
//       /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
//     }
//   }

//   _addNewPhotos() async {
//     setState(() {
//       _isFetching = true;
//     });
//     List<AssetEntity> photos = await _albums.first.getAssetListPaged(_currentPage, _pageSize);
//     if(photos.length < _pageSize) {
//       setState(() {
//         _hasReachedMax = true;
//       });
//     }
//     List<Uint8List> thumbnails = [];
//     for(var photo in photos){
//       thumbnails.add(await photo.thumbDataWithSize(150, 150));
//     }
//     print(_photoList);
//     print(_albums);
//     setState(() {
//       _photoList.addAll(photos);
//       _thumbnailList.addAll(thumbnails);
//       _currentPage++;
//     });
//     setState(() {
//       _isFetching = false;
//     });
//   }

//   void _onScroll() {
//     if(_isFetching) {
//       return;
//     }
//     if (!_hasReachedMax) {
//       final maxScroll = widget.scrollController.position.maxScrollExtent;
//       final currentScroll = widget.scrollController.position.pixels;
//       if (maxScroll - currentScroll <= _scrollThreshold) {
//         _addNewPhotos();
//       }
//     }
//   }
// }

// /*
// * final LocalImageProvider _localImageProvider = LocalImageProvider();
//   bool _hasPermission = false;
//   Set<SelectedImageModel> _localDeviceImages = Set();
//   Set<SelectedImageModel> _selectedImages = Set();

//   Future<void> _requestPermission() async {
//     bool permission = await _localImageProvider.initialize();
//     setState(() {
//       _hasPermission = permission;
//     });
//   }

//   void _addLocalImages(List<LocalImage> localImages) {
//     setState(() {
//       _localDeviceImages.addAll(Iterable.generate(localImages.length, (index) {
//         return SelectedImageModel(deviceImage: DeviceImage(localImages[index]));
//       }));
//       _localDeviceImages.forEach((element) {element.isSelected = false;});
//     });

//   }

//   void loadImages() async {
//     await _requestPermission();
//     if (_hasPermission) {
//       List<LocalAlbum> localAlbums = await _localImageProvider.findAlbums(LocalAlbumType.all);
//       for (var album in localAlbums) {
//         print(album.title);
//         List<LocalImage> localImages = await _localImageProvider.findImagesInAlbum(album.id, album.imageCount);
//         _addLocalImages(localImages);
//       }
//     } else {
//       print("The user has denied access to images on their device.");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     loadImages();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       controller: widget.scrollController,
//       slivers: <Widget>[
//         SliverToBoxAdapter(
//           child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: <Widget>[
//                 Text('Selected ${_selectedImages.length}',
//                     style: Theme.of(context).textTheme.bodyText1),
//                 FlatButton(
//                   onPressed: () async {
//                     //send images
//                     if(_selectedImages.isNotEmpty) {
//                       Set<Uint8List> toSend = Set();
//                       for (var image in _selectedImages) {
//                         toSend.add(await image.getImageBytes());
//                       }
//                       File file = File.fromRawPath(toSend.first);
//                       print('Successfully Sent');
//                       Navigator.pop(context);
//                     }
//                   },
//                   child: Text('Send', style: Theme.of(context).textTheme.bodyText1),
//                 )
//               ]
//           ),
//         ),
//         SliverGrid(
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3
//           ),
//           delegate: SliverChildBuilderDelegate(
//                 (context, index) {
//               return Material(
//                 child: InkResponse(
//                   onTap: () {
//                     if (_localDeviceImages.elementAt(index).isSelected) {
//                       setState(() {
//                         _localDeviceImages.elementAt(index).isSelected = false;
//                         _selectedImages.remove(_localDeviceImages.elementAt(index));
//                       });
//                       print('DeSelected');
//                     }else {
//                       setState(() {
//                         _localDeviceImages.elementAt(index).isSelected = true;
//                         _selectedImages.add(_localDeviceImages.elementAt(index));
//                       });
//                       print('Selected');
//                     }
//                     print(_selectedImages.length);
//                   },
//                   child: Image(
//                     image: _localDeviceImages.elementAt(index).deviceImage,
//                     color: _localDeviceImages.elementAt(index).isSelected ? Colors.white70 : Colors.transparent,
//                     colorBlendMode: BlendMode.lighten,
//                   ),
//                 ),
//               );
//             },
//             childCount: _localDeviceImages.length,
//           ),
//         ),
//       ],
//     );
//   }*/
