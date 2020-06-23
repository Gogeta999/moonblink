import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class StatusBarUtils {

  /// Status bar will change with theme
  /// from AnnotatedRegion<SystemUiOverlayStyle>
  static systemUiOverlayStyle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
  }
}
