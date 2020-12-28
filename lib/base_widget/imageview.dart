import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatelessWidget {
  final String img;
  ImageView(this.img);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      PhotoView(
        imageProvider: CachedNetworkImageProvider(img),
        maxScale: PhotoViewComputedScale.covered * 5,
        minScale: PhotoViewComputedScale.contained * 0.7,
      ),
      Positioned(
        right: 10,
        top: 30,
        child: IconButton(
            color: Colors.grey,
            iconSize: 40,
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            }),
      )
    ]));
  }
}

class LocalImageView extends StatelessWidget {
  final Uint8List img;
  LocalImageView(this.img);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        PhotoView(
          imageProvider: MemoryImage(img),
          maxScale: PhotoViewComputedScale.covered * 5,
          minScale: PhotoViewComputedScale.contained * 0.7,
        ),
        Positioned(
          right: 10,
          top: 30,
          child: IconButton(
              iconSize: 40,
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              }),
        )
      ]),
    );
  }
}

///null one to switch local and cache
class FullScreenImageView extends StatelessWidget {
  final File image;
  final String imageUrl;

  FullScreenImageView({this.image, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            color: Theme.of(context).accentColor,
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context)),
      ),
      body: PhotoView(
        imageProvider: image == null
            ? CachedNetworkImageProvider(imageUrl)
            : FileImage(image),
      ),
    );
  }
}
