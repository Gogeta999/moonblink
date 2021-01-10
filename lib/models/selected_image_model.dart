import 'dart:typed_data';

class SelectedImageModel {
  bool isSelected;
  Uint8List thumbnail;
  int duration;
  String formattedDuration;

  SelectedImageModel({this.isSelected = false, this.thumbnail, this.duration, this.formattedDuration});
}
