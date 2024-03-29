import 'package:flutter/cupertino.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/provider/view_state_list_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// Base on
abstract class ViewStateRefreshListModel<T> extends ViewStateListModel<T> {
  /// First page
  static const pageNumFirst = 1;

  /// Post limit
  static const postlimt = 5;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  RefreshController get refreshController => _refreshController;

  /// Current page
  int _currentPageNum = pageNumFirst;

  /// pull down to get more
  /// [init] loadmore at init or not
  /// true: Error, need to jump page
  /// false: Error, doesn't jump and showing error
  Future<List<T>> refresh({bool init = false}) async {
    try {
      _currentPageNum = pageNumFirst;
      var data = await loadData(pageNum: pageNumFirst);
      if (data.isEmpty) {
        refreshController.refreshCompleted(resetFooterState: true);
        list.clear();
        setEmpty();
      } else {
        onCompleted(data);
        list.clear();
        list.addAll(data);
        refreshController.refreshCompleted();
        // if lower than post limit, abandon to pull to load more
        if (data.length < postlimt) {
          refreshController.loadNoData();
        } else {
          //avoid to get error from pull to load more, set Idle to be safe
          refreshController.loadComplete();
        }
        setIdle();
      }
      return data;
    } catch (e, s) {
      /// catch to debug
      if (init) list.clear();
      refreshController.refreshFailed();
      setError(e, s);
      return null;
    }
  }

  /// pull to top to load more
  Future<List<T>> loadMore() async {
    try {
      var data = await loadData(pageNum: ++_currentPageNum);
      print("Current Page Is - $_currentPageNum");
      if (data.isEmpty) {
        _currentPageNum--;
        refreshController.loadNoData();
      } else {
        onCompleted(data);
        list.addAll(data);
        if (data.length < postlimt) {
          refreshController.loadNoData();
        } else {
          refreshController.loadComplete();
        }
        notifyListeners();
      }
      return data;
    } catch (e, s) {
      _currentPageNum--;
      refreshController.loadFailed();
      if (isDev) debugPrint('error--->\n' + e.toString());
      if (isDev) debugPrint('statck--->\n' + s.toString());
      return null;
    }
  }

  // load data
  Future<List<T>> loadData({int pageNum});

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
