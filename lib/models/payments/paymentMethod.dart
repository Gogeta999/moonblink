import 'package:flutter/gestures.dart';

class PaymentMethod {
  String title;
  String method;
  String id;
  String image;
  TapGestureRecognizer recognizer;
  PaymentMethod(
      {this.title, this.method, this.id, this.image, this.recognizer});
}
