import 'package:flutter/material.dart';

class TapToTopModel with ChangeNotifier{
  ScrollController _scrollController;
  double _height;
  bool _showTopBtn = false;
  final _scrollThreshold = 1000.0;
  bool _isFetching = false;

  ScrollController get scrollController => _scrollController;

  bool get showTopBtn => _showTopBtn;
  
  TapToTopModel(this._scrollController, {double height: 200}) {
    _height = height;
  }

  init(Future<List<dynamic>> Function() loadMore) {
    _scrollController.addListener(() {
      if (_scrollController.offset > _height && !_showTopBtn) {
        _showTopBtn = true;
        notifyListeners();
      } else if (_scrollController.offset < _height && _showTopBtn) {
        _showTopBtn = false;
        notifyListeners();
      }
      onScroll(loadMore);
    });
  }

  onScroll(Future<List<dynamic>> Function() loadMore) async {
    if (_isFetching) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _isFetching = true;
      //print('IsFetching');
      //await loadMore();
      _isFetching = false;
    }
  }

  scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(milliseconds: 300), curve: Curves.easeOutCubic);
  }  
}