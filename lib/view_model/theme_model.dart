import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/ui/helper/theme_helper.dart';

//const Color(0xFF5394FF),

class ThemeModel with ChangeNotifier {
  static const mThemeColorIndex = 'mThemeColorIndex';
  static const mThemeUserDarkMode = 'mThemeUserDarkMode';
  static const mFontIndex = 'mFontIndex';

  static const fontValueList = ['system'];

  /// user's choosing mode
  bool _userDarkMode;

  /// current theme
  MaterialColor _themeColor;

  // font index
  int _fontIndex;

  ThemeModel() {
    /// user didn't choose darkmode
    _userDarkMode =
        StorageManager.sharedPreferences.getBool(mThemeUserDarkMode) ?? false;

    /// get theme
    _themeColor = Colors.primaries[
        StorageManager.sharedPreferences.getInt(mThemeColorIndex) ?? 5];

    /// get font
    _fontIndex = StorageManager.sharedPreferences.getInt(mFontIndex) ?? 0;
  }

  int get fontIndex => _fontIndex;

  ///
  /// if not pass [brightness] brightness then this will not change
  void switchTheme({bool userDarkMode, MaterialColor color}) {
    _userDarkMode = userDarkMode ?? _userDarkMode;
    _themeColor = color ?? _themeColor;
    notifyListeners();
    saveTheme2Storage(_userDarkMode, _themeColor);
  }

  ///
  /// random theme
  void switchRandomTheme({Brightness brightness}) {
    int colorIndex = Random().nextInt(Colors.primaries.length - 1);
    switchTheme(
      userDarkMode: Random().nextBool(),
      color: Colors.primaries[colorIndex],
    );
  }

  //
  switchFont(int index) {
    _fontIndex = index;
    switchTheme();
    saveFontIndex(index);
  }

  /// dark mode will auto change with suitable theme
  /// [dark]
  themeData({bool platformDarkMode: false}) {
    var isDark = platformDarkMode || _userDarkMode;
    Brightness brightness = isDark ? Brightness.dark : Brightness.light;

    var themeColor = _themeColor;
    var accentColor = isDark ? themeColor[700] : _themeColor;
    var themeData = ThemeData(
        brightness: brightness,
        // 主题颜色属于亮色系还是属于暗色系(eg:dark时,AppBarTitle文字及状态栏文字的颜色为白色,反之为黑色)
        // 这里设置为dark目的是,不管App是明or暗,都将appBar的字体颜色的默认值设为白色.
        // 再AnnotatedRegion<SystemUiOverlayStyle>的方式,调整响应的状态栏颜色
        primaryColorBrightness: Brightness.dark,
        accentColorBrightness: Brightness.dark,
        primarySwatch: themeColor,
        accentColor: accentColor,
        fontFamily: fontValueList[fontIndex]);

    themeData = themeData.copyWith(
      brightness: brightness,
      accentColor: accentColor,
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: themeColor,
        brightness: brightness,
      ),

      appBarTheme: themeData.appBarTheme.copyWith(elevation: 0),
      splashColor: themeColor.withAlpha(50),
      hintColor: themeData.hintColor.withAlpha(90),
      errorColor: Colors.red,
      cursorColor: accentColor,
      textTheme: themeData.textTheme.copyWith(

          /// 解决中文hint不居中的问题 https://github.com/flutter/flutter/issues/40248
          subtitle2: themeData.textTheme.subtitle2
              .copyWith(textBaseline: TextBaseline.alphabetic)),
      textSelectionColor: accentColor.withAlpha(60),
      textSelectionHandleColor: accentColor.withAlpha(60),
      toggleableActiveColor: accentColor,
      chipTheme: themeData.chipTheme.copyWith(
        pressElevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 10),
        labelStyle: themeData.textTheme.caption,
        backgroundColor: themeData.chipTheme.backgroundColor.withOpacity(0.1),
      ),
//          textTheme: CupertinoTextThemeData(brightness: Brightness.light)
      inputDecorationTheme: ThemeHelper.inputDecorationTheme(themeData),
    );
    return themeData;
  }

  /// shared preferences
  saveTheme2Storage(bool userDarkMode, MaterialColor themeColor) async {
    var index = Colors.primaries.indexOf(themeColor);
    await Future.wait([
      StorageManager.sharedPreferences
          .setBool(mThemeUserDarkMode, userDarkMode),
      StorageManager.sharedPreferences.setInt(mThemeColorIndex, index)
    ]);
  }

  /// 根据索引获取字体名称,这里牵涉到国际化
  static String fontName(index, context) {
    switch (index) {
      case 0:
        return S.of(context).autoBySystem;
      // case 1:
      //   return S.of(context).fontKuaiLe;
      default:
        return '';
    }
  }

  /// 字体选择持久化
  static saveFontIndex(int index) async {
    await StorageManager.sharedPreferences.setInt(mFontIndex, index);
  }
}
