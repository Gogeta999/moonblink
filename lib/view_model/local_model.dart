import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';

class LocaleModel extends ChangeNotifier {
//  static const localeNameList = ['auto', '中文', 'English'];
  static const localeValueList = ['', 'en', 'mm', 'zh'];

  //
  static const mLocaleIndex = 'mLocaleIndex';

  int _localeIndex;

  int get localeIndex => _localeIndex;

  Locale get locale {
    if (_localeIndex > 0) {
      var value = localeValueList[_localeIndex].split("-");
      return Locale(value[0], value.length == 2 ? value[1] : '');
    }
    // 跟随系统
    return null;
  }

  LocaleModel() {
    _localeIndex = StorageManager.sharedPreferences.getInt(mLocaleIndex) ?? 0;
  }

  switchLocale(int index) {
    _localeIndex = index;
    notifyListeners();
    StorageManager.sharedPreferences.setInt(mLocaleIndex, index);
  }

  static String localeName(index, context) {
    switch (index) {
      case 0:
        return S.of(context).autoBySystem;
      case 1:
        return S.of(context).english;
      case 2:
        return 'S.of(context).burmese';
      case 3:
        return S.of(context).china;
      default:
        return '';
    }
  }
}
