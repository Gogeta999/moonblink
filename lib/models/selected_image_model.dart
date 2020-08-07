import 'dart:typed_data';

import 'package:local_image_provider/device_image.dart';
import 'package:local_image_provider/local_image_provider.dart';

///old
class SelectedImageModel {
  bool isSelected;
  DeviceImage deviceImage;

  SelectedImageModel({this.isSelected = false, this.deviceImage});

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final SelectedImageModel typedOther = other;
    return deviceImage.localImage.id == typedOther.deviceImage.localImage.id &&
        deviceImage.scale == typedOther.deviceImage.scale;
  }

  @override
  int get hashCode => deviceImage.localImage.hashCode;

  Future<Uint8List> getImageBytes() async {
    return await LocalImageProvider().imageBytes(
        this.deviceImage.localImage.id,
        this.deviceImage.localImage.pixelHeight,
        this.deviceImage.localImage.pixelWidth);
  }
}

///too slow
/*
class SelectedImageModel {
  bool isSelected;
  Uint8List imageRawBytes;

  SelectedImageModel({this.isSelected = false, this.imageRawBytes});

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final SelectedImageModel typedOther = other;
    return imageRawBytes == typedOther.imageRawBytes;
  }

  @override
  int get hashCode => imageRawBytes.hashCode;
}*/
