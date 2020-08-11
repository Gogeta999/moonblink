import 'dart:typed_data';

class SelectedImageModel {
  bool isSelected;
  Uint8List thumbnail;

  SelectedImageModel({this.isSelected = false, this.thumbnail});
}
