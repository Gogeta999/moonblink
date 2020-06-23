import 'package:flutter/widgets.dart';

class GlobalFavouriteStateModel extends ChangeNotifier{
  static final Map<int, bool> _map = Map();

  contains(id) {
    return _map.containsKey(id);
  }
  
  operator [](int id) {
    return _map[id];
  }
}