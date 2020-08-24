import 'package:flutter/cupertino.dart';
import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/constants.dart';

//Base
abstract class ViewStateListModel<T> extends ViewStateModel {
  /// PageData
  List<T> list = [];

  /// First time will go to loading skeleton
  initData() async {
    setBusy();
    await refresh(init: true);
  }

  // Pull down to refresh
  refresh({bool init = false}) async {
    try {
      List<T> data = await loadData();
      if (data.isEmpty) {
        list.clear();
        setEmpty();
      } else {
        onCompleted(data);
        list.clear();
        list.addAll(data);
        setIdle();
      }
    } catch (e, s) {
      if (init) list.clear();
      setError(e, s);
    }
  }

  ///only for home posts
  Future<bool> removeItem({@required int index, @required int blockUserId}) async {
    try {
      await MoonBlinkRepository.blockOrUnblock(blockUserId, BLOCK);
      list.removeAt(index);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Load data
  Future<List<T>> loadData();
  // Load with partner data
  onCompleted(List<T> data) {}
}
