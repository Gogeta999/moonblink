import 'package:flutter/cupertino.dart';
import 'package:moonblink/provider/view_state_list_model.dart';
import 'package:moonblink/provider/view_state_list_refresh_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kLocalStorageSearch = 'kLocalStorageSearch';
const String kSearchHistory = 'kSearchHistory';

class SearchHistoryModel extends ViewStateListModel<String> {
  clearHistory() async {
    debugPrint('clearHistory');
    var sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(kSearchHistory);
    list.clear();
    setEmpty();
  }

  addHistory(String keyword) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var histories = sharedPreferences.getStringList(kSearchHistory) ?? [];
    histories
      ..remove(keyword)
      ..insert(0, keyword);
    await sharedPreferences.setStringList(kSearchHistory, histories);
    notifyListeners();
  }

  @override
  Future<List<String>> loadData() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getStringList(kSearchHistory) ?? [];
  }
}

class SearchResultModel extends ViewStateRefreshListModel {
  final String keyword;
  final SearchHistoryModel searchHistoryModel;

  SearchResultModel({this.keyword, this.searchHistoryModel});

  @override
  Future<List> loadData({int pageNum}) async {
    if (keyword.isEmpty) return [];
    searchHistoryModel.addHistory(keyword);
    return await MoonBlinkRepository.fetchSearchResults(
        key: keyword, pageNum: pageNum);
  }
}
