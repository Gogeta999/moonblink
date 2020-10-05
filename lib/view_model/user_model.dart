import 'package:flutter/cupertino.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/user.dart';
import 'package:moonblink/view_model/favorite_model.dart';

import 'login_model.dart';

const String mUser = 'mUser';

class UserModel extends ChangeNotifier {
  // static const String mUser = 'mUser';

  final GlobalFavouriteStateModel globalFavouriteStateModel;

  User _user;

  User get user => _user;

  bool get hasUser => user != null;

  UserModel({this.globalFavouriteStateModel}) {
    var userMap = StorageManager.localStorage.getItem(mUser);
    _user = userMap != null ? User.fromJsonMap(userMap) : null;
  }

  saveUser(User user) {
    _user = user;
    print('sdfwerrefsgdsg' + user.toString());
    StorageManager.localStorage.setItem(mUser, user);
    notifyListeners();
  }

  /// clear user data
  clearUser() {
    _user = null;
    notifyListeners();
    StorageManager.localStorage.deleteItem(mUser);
    StorageManager.sharedPreferences.remove(token);
    StorageManager.sharedPreferences.remove(mLoginName);
    StorageManager.sharedPreferences.remove(mUserId);
    StorageManager.sharedPreferences.remove(mUserType);
    StorageManager.sharedPreferences.remove(mstatus);
    StorageManager.sharedPreferences.remove(mUserProfile);
    StorageManager.sharedPreferences.remove(mgameprofile);
    //StorageManager.sharedPreferences.clear();
  }
}
