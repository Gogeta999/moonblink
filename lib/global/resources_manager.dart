import 'package:flutter/material.dart';

class ImageHelper{

  static String wrapAssetsLogo(String url){
    return "assets/logos/" + url;
  }

  static String wrapAssetsImage(String url){
    return "assets/images/" + url;
  }

  static Widget error({double width, double height, double size}) {
    return SizedBox(
        width: width,
        height: height,
        child: Icon(
          Icons.error_outline,
          size: size,
        ));
  }
}

class IconFonts {
  IconFonts._();

  /// iconfont:flutter base
  static const String fontFamily = 'iconfont';
  //Here to show defalut error on some pages
  static const IconData pageEmpty = IconData(0xe63c, fontFamily: fontFamily);
  static const IconData pageError = IconData(0xe600, fontFamily: fontFamily);
  static const IconData pageNetworkError = IconData(0xe678, fontFamily: fontFamily);
  static const IconData pageUnAuth = IconData(0xe65f, fontFamily: fontFamily);
}
