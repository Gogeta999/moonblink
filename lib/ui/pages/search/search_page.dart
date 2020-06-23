import 'package:flutter/material.dart' hide SearchDelegate;
import 'package:flutter/cupertino.dart';
import 'package:moonblink/base_widget/custom_flutter_src/search.dart';
import 'package:moonblink/ui/pages/search/search_results.dart';
import 'package:moonblink/ui/pages/search/search_suggestions.dart';
import 'package:moonblink/view_model/search_model.dart';
import 'package:provider/provider.dart';

class SearchPage extends SearchDelegate{
  SearchHistoryModel _searchHistoryModel = SearchHistoryModel();
  @override
  ThemeData appBarTheme(BuildContext context) {
    var theme = Theme.of(context);
    return super.appBarTheme(context).copyWith(
        primaryColor: theme.scaffoldBackgroundColor,
        primaryColorBrightness: theme.brightness);
  }
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
            showSuggestions(context);
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    debugPrint('buildResults-query ' + query);
    if (query.length > 0) {
      return SearchResults(
          keyword: query, searchHistoryModel: _searchHistoryModel,);
    }
    return SizedBox.shrink();
    // return ListView();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SearchHistoryModel>.value(value: _searchHistoryModel),

      ],
      child: SearchSuggestions(delegate: this),
      );
    // return Container(
    //   height: 20,
    //   // color: Colors.black,
    //   child: Text('Search Suggestions here'),
    // );
    // return SizedBox.shrink(
      
    // );
  }

  @override 
  void close(BuildContext context, result){
    _searchHistoryModel.dispose();
    super.close(context, result);
  }
}
