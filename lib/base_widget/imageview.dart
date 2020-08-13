import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatelessWidget {
  final String img;
  ImageView(this.img);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      PhotoView(
        imageProvider: NetworkImage(img),
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
