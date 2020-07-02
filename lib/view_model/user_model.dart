import 'package:flutter/cupertino.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/user.dart';
import 'package:moonblink/view_model/favorite_model.dart';

class UserModel extends ChangeNotifier {
  static const String mUser = 'mUser';

  final GlobalFavouriteStateModel globalFavouriteStateModel;

  User _user;

  User get user => _user;

  bool get hasUser => user != null;

  UserModel({@required this.globalFavouriteStateModel}) {
    var userMap = StorageManager.localStorage.getItem(mUser);
    _user = userMap != null ? User.fromJsonMap(userMap) : null;
  }

  saveUser(User user) {
    _user = user;
    notifyListeners();
    StorageManager.localStorage.setItem(mUser, user);
  }

  /// clear user data
  clearUser() {
    _user = null;
    notifyListeners();
    StorageManager.localStorage.deleteItem(mUser);
    StorageManager.sharedPreferences.clear();
  }
}
