import 'package:flutter/material.dart';

class ImageHelper {
  static String wrapAssetsLogo(String url) {
    return "assets/logos/" + url;
  }

  static String wrapAssetsSvg(String url) {
    return "assets/icons/" + url;
  }

  static String wrapUserPageAssetsSvg(String url) {
    return "assets/icons/user/page/" + url;
  }

  static String wrapAssetsImage(String url) {
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
  //AliIcon
  static const String fontFamily = 'appIconFonts';
  //Camera Icon
  static const IconData cameraIcon = IconData(0xe657, fontFamily: fontFamily);
  //Noti Icon
  static const IconData bookingHistoryIcon =
      IconData(0xe674, fontFamily: fontFamily);
  static const IconData systemNotiIcon =
      IconData(0xe638, fontFamily: fontFamily);
  //Button Icon
  static const IconData messageIcon = IconData(0xe605, fontFamily: fontFamily);
  static const IconData sendIcon = IconData(0xe603, fontFamily: fontFamily);
  static const IconData voieMsgIcon = IconData(0xe659, fontFamily: fontFamily);
  static const IconData dayModeIcon = IconData(0xe64e, fontFamily: fontFamily);
  static const IconData setProfileIcon =
      IconData(0xe65d, fontFamily: fontFamily);
  //Page Icon
  static const IconData homePageIcon = IconData(0xe607, fontFamily: fontFamily);
  static const IconData chatPageIcon = IconData(0xe670, fontFamily: fontFamily);
  static const IconData followingPageIcon =
      IconData(0xe6a2, fontFamily: fontFamily);
  static const IconData statusPageIcon =
      IconData(0xe71e, fontFamily: fontFamily);

  /// iconfont:flutter base
  // static const String fontFamily = 'iconfont';
  //Here to show defalut error on some pages
  static const IconData pageEmpty = IconData(0xe622, fontFamily: fontFamily);
  static const IconData pageError = IconData(0xe6bf, fontFamily: fontFamily);
  static const IconData pageNetworkError =
      IconData(0xe6d0, fontFamily: fontFamily);
  static const IconData pageUnAuth = IconData(0xe60c, fontFamily: fontFamily);
}
