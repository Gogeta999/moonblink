import 'dart:io';

import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StorageManager {
  /// app's global config eg:theme
  static SharedPreferences sharedPreferences;

  /// temporary directory eg: cookie
  static Directory temporaryDirectory;


  /// initial storage eg:user数据
  static LocalStorage localStorage;

  /// necessary initial storage
  /// sync will cause app delayed
  /// 由于是同步操作会导致阻塞,所以应尽量减少存储容量
  static init() async {
    // async 异步操作
    // sync 同步操作
    temporaryDirectory = await getTemporaryDirectory();
    sharedPreferences = await SharedPreferences.getInstance();
    localStorage = LocalStorage('LocalStorage');
    await localStorage.ready;
  }
}
