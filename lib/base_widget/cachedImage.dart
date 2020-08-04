import 'package:flutter/material.dart';

class CachedImage extends StatefulWidget {
  const CachedImage({Key key, @required this.imageProvider, this.boxFit})
      : assert(imageProvider != null),
        super(key: key);
  final boxFit;
  final ImageProvider imageProvider;

  @override
  _CachedImageState createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  ImageStream _imageStream;
  ImageInfo _imageInfo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // if url change then dependencie also change with this
    _getImage();
  }

  @override
  void didUpdateWidget(CachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) _getImage();
  }

  void _getImage() {
    final ImageStream oldImageStream = _imageStream;
    // use imageProvider.resolve to solve，get ImageStream。
    _imageStream =
        widget.imageProvider.resolve(createLocalImageConfiguration(context));
    //Check Image dependecies is same or not，if different will refresh image
    if (_imageStream.key != oldImageStream?.key) {
      final ImageStreamListener listener = ImageStreamListener(_updateImage);
      oldImageStream?.removeListener(listener);
      _imageStream.addListener(listener);
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      // Trigger a build whenever the image changes.
      _imageInfo = imageInfo;
    });
  }

  @override
  void dispose() {
    _imageStream.removeListener(ImageStreamListener(_updateImage));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawImage(
      image: _imageInfo?.image, // this is a dart:ui Image object
      scale: _imageInfo?.scale ?? 1.0,
      fit: widget.boxFit,
    );
  }
}
